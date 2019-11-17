% based on https://discordapp.com/developers/docs/topics/permissions#permission-overwrites

:- consult(flags).

% all permissions granted
flag("ALL", 0x7fffffff).
% no permissions granted
flag("NONE", 0x00000000).

% computes a member's base permissions integer
% given member and guild
base_permissions(Member, Guild, Roles, Permissions) :-
	guild_owner(Member, Guild, P1),
	flag("NONE", P2),
	guild_roles(Member, Guild, Roles, P2, P3),
	guild_admin(P3, P4),
	Permissions is P1 \/ P4.

% helpers for base_permissions:

% member is guild owner
guild_owner(Member, Guild, Permissions) :-
	Member.user.id = Guild.owner_id,
	flag("ALL", Permissions).
% member is not guild owner
guild_owner(Member, Guild, Permissions) :-
	Member.user.id \= Guild.owner_id,
	flag("NONE", Permissions).

% given member and list of roles in guild,
% produces combined permissions integer
% guild_roles(Member, Guild, [Role], PermsIn, PermsOut).
guild_roles(_, _, [], P, P).
% @everyone has role.id = guild.id
guild_roles(M, G, [H|T], P, R) :-
	H.id = G.id,
	P1 is P \/ H.permissions,
	guild_roles(M, G, T, P1, R).
% member has role
guild_roles(M, G, [H|T], P, R) :-
	memberchk(H.id, M.roles),
	P1 is P \/ H.permissions,
	guild_roles(M, G, T, P1, R).
% member does not have role
guild_roles(M, G, [H|T], P, R) :-
	H.id \= G.id,
	\+ memberchk(H.id, M.roles),
	guild_roles(M, G, T, P, R).


% PermsIn has administrator
% guild_admin(PermsIn, PermsOut).
guild_admin(P, R) :-
	has_permission(P, "ADMINISTRATOR"),
	flag("ALL", R).
% member is not administrator
guild_admin(P, P) :-
	\+ has_permission(P, "ADMINISTRATOR").


% computes a member's permissions integer
% given base permissions and channel

% base is administrator
overwrite_permissions(_, _, Base, Permissions) :-
	has_permission(Base, "ADMINISTRATOR"),
	flag("ALL", Permissions).
% base is not administrator
overwrite_permissions(Member, Channel, Base, Permissions) :-
	\+ has_permission(Base, "ADMINISTRATOR"),
	channel_everyone(Channel, Base, P1),
	flag("NONE", N),
	channel_roles(Channel.permission_overwrites, Channel.guild_id, N, N, Deny, Allow),
	P2 is P1 /\ \Deny \/ Allow, 
	channel_member(Channel.permission_overwrites, Member, P2, Permissions).

% helpers for overwrite_permissions:

% given a channel, applies @everyone overwrites
channel_everyone(Channel, Base, Permissions) :-
	member(Everyone, Channel.permission_overwrites),
	Everyone.id = Channel.guild_id, % can this throw an error? @everyone overwrite may not exist
	Deny is Base /\ \Everyone.deny,
	Permissions is Deny \/ Everyone.allow.

% given a list of overwrites and a channel,
% produces combined permissions integers for roles
% channel_roles([Overwrite], GuildID, DenyIn, AllowIn, Deny, Allow).
channel_roles([], _, D, A, D, A).
% ignore non-role overwrites
channel_roles([H|T], GID, D1, A1, D2, A2) :-
	H.type \= "role",
	channel_roles(T, GID, D1, A1, D2, A2).
% ignore @everyone overwrites
channel_roles([H|T], GID, D1, A1, D2, A2) :-
	H.id = GID,
	channel_roles(T, GID, D1, A1, D2, A2).
% role overwrites
channel_roles([H|T], GID, D1, A1, D2, A2) :-
	H.type = "role",
	H.id \= GID,
	D3 is D1 \/ H.deny,
	A3 is A1 \/ H.allow,
	channel_roles(T, GID, D3, A3, D2, A2).

% given a list of overwrites, member, and initial permissions,
% produces combined permissions integer for members
% channel_member([Overwrite], Member, PermsIn, PermsOut).
channel_member([], _, P, P).
% ignore non-member overwrites
channel_member([H|T], M, PIn, POut) :-
	H.type \= "member",
	channel_member(T, M, PIn, POut).
% overwrites doesn't match member id
channel_member([H|T], M, PIn, POut) :-
	H.type = "member",
	H.id \= M.user.id,
	channel_member(T, M, PIn, POut).
% overwrite matches member id
channel_member([H|_], M, PIn, POut) :-
	H.type = "member",
	H.id = M.user.id,
	Deny is PIn /\ \H.deny,
	POut is Deny \/ H.allow.


% given a member of a guild and a channel in the guild,
% produces the member's permissions considering overwrites
	% Member, Guild, Channel as dicts
	% Permissions as integer 0x########
% TODO: alternatively, get Guild and Roles based on Channel (from guild_id) rather than passing args
permissions(Member, Guild, Channel, Roles, Permissions) :-
	base_permissions(Member, Guild, Roles, Base),
	overwrite_permissions(Member, Channel, Base, Permissions).

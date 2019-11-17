% based on https://discordapp.com/developers/docs/topics/permissions#permission-overwrites

:- consult(flags).

% all permissions granted
flag("ALL", 0x7fffffff).
% no permissions granted
flag("NONE", 0x00000000).

% computes a member's base permissions integer
% given member and guild
base_permissions(Member, Guild, Permissions) :-
	guild_owner(Member, Guild, P1),
	flag("NONE", P2),
	guild_roles(Member.roles, P2, P3),
	guild_admin(P3, P4),
	Permissions is P1 \/ P4.

% helpers for base_permissions:

% member is guild owner
guild_owner(Member, Guild, Permissions) :-
	Member.id =:= Guild.owner_id,
	flag("ALL", Permissions).
% member is not guild owner
guild_owner(Member, Guild, Permissions) :-
	Member.id =\= Guild.owner_id,
	flag("NONE", Permissions).

% given a list of roles, produces combined permissions integer
	% includes @everyone, which has role.id == guild.id
% guild_roles([Role], PermsIn, PermsOut).
guild_roles([], P, P).
guild_roles([H|T], P, R) :-
	P1 is P \/ H.permissions,
	guild_roles(T, P1, R).

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
	channel_roles(Channel.permission_overwrites, Channel.guild_id, P1, P2),
	channel_member(Channel.permission_overwrites, Member, P2, Permissions).

% helpers for overwrite_permissions:

% given a channel, applies @everyone overwrites
channel_everyone(Channel, Base, Permissions) :-
	member(Everyone, Channel.permission_overwrites),
	Everyone.id =:= Channel.guild_id, % can this throw an error? @everyone overwrite may not exist
	Deny is Base /\ \Everyone.deny,
	Permissions is Deny \/ Everyone.allow.

% given a list of overwrites, channel, and initial permissions,
% produces combined permissions integer for roles
% channel_roles([Overwrite], GuildID, Base, Permissions).
channel_roles([], _, P, P).
% ignore member overwrites
channel_roles([H|T], GID, P, R) :-
	H.type = "member",
	channel_roles(T, GID, P, R).
% ignore @everyone overwrites
channel_roles([H|T], GID, P, R) :-
	H.id =:= GID,
	channel_roles(T, GID, P, R).
% role overwrites
channel_roles([H|T], GID, P, R) :-
	H.type \= "member",
	H.id =\= GID,
	D is P /\ \H.deny,
	P1 is D \/ H.allow,
	channel_roles(T, GID, P1, R).

% given a list of overwrites, member, and initial permissions,
% produces combined permissions integer for members
% channel_member([Overwrite], Member, PermsIn, PermsOut).
channel_member(Overwrites, Member, PermsIn, PermsOut) :-
	member(MemberOverwrite, Overwrites),
	MemberOverwrite.type = "member",
	MemberOverwrite.id =:= Member.id,
	Deny is PermsIn /\ \MemberOverwrite.deny,
	PermsOut is Deny \/ MemberOverwrite.allow.


% given a member of a guild and a channel in the guild,
% produces the member's permissions considering overwrites
	% Member, Guild, Channel as dicts
	% Permissions as integer 0x########
permissions(Member, Guild, Channel, Permissions) :-
	base_permissions(Member, Guild, Base),
	overwrite_permissions(Member, Channel, Base, Permissions).

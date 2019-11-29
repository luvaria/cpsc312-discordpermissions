% flags as documented at https://discordapp.com/developers/docs/topics/permissions

% Note: 2FA requirement is not represented

% flag(Permission, Value, [ChannelType]).
	% ChannelType:
	% []: guild-level role permission only
	% "T": Text
	% "V": Voice
flag("CREATE_INSTANT_INVITE", 0x00000001, ["T", "V"]).
flag("KICK_MEMBERS", 0x00000002, []).
flag("BAN_MEMBERS", 0x00000004, []).
flag("ADMINISTRATOR", 0x00000008, []).
flag("MANAGE_CHANNELS", 0x00000010, ["T", "V"]).
flag("MANAGE_GUILD", 0x00000020, []).
flag("ADD_REACTIONS", 0x00000040, ["T"]).
flag("VIEW_AUDIT_LOG", 0x00000080, []).
flag("VIEW_CHANNEL", 0x00000400, ["T", "V"]).
flag("SEND_MESSAGES", 0x00000800, ["T"]).
flag("SEND_TTS_MESSAGES", 0x00001000, ["T"]).
flag("MANAGE_MESSAGES", 0x00002000, ["T"]).
flag("EMBED_LINKS", 0x00004000, ["T"]).
flag("ATTACH_FILES", 0x00008000, ["T"]).
flag("READ_MESSAGE_HISTORY", 0x00010000, ["T"]).
flag("MENTION_EVERYONE", 0x00020000, ["T"]).
flag("USE_EXTERNAL_EMOJIS", 0x00040000, ["T"]).
flag("CONNECT", 0x00100000, ["V"]).
flag("SPEAK", 0x00200000, ["V"]).
flag("MUTE_MEMBERS", 0x00400000, ["V"]).
flag("DEAFEN_MEMBERS", 0x00800000, ["V"]).
flag("MOVE_MEMBERS", 0x01000000, ["V"]).
flag("USE_VAD", 0x02000000, ["V"]).
flag("PRIORITY_SPEAKER", 0x00000100, ["V"]).
flag("STREAM", 0x00000200, ["V"]).
flag("CHANGE_NICKNAME", 0x04000000, []).
flag("MANAGE_NICKNAMES", 0x08000000, []).
flag("MANAGE_ROLES", 0x10000000, ["T", "V"]).
flag("MANAGE_WEBHOOKS", 0x20000000, ["T", "V"]).
flag("MANAGE_EMOJIS", 0x40000000, []).

% all permissions granted
flag("ALL", 0x7fffffff, []).
% no permissions granted
flag("NONE", 0x00000000, []).

% true when given permissions integer matches permission flag
% try: has_permission(0x00000003, "CREATE_INSTANT_INVITE").
has_permission(Integer, Permission) :-
	flag(Permission, Mask, _),
	Mask =:= Mask /\ Integer.

:- use_module(library(http/http_open)).
:- use_module(library(http/json)).

% gets bot_token("Bot {token}") defined in token.pl
% e.g. bot_token("Bot a9ekflwef2.f9sklefj02fs.sefesfsefsfeafmYc")
% associated bot must be a member of the guild whose data is requested
% token.pl is intentionally not pushed to remote repo to protect tokens
:- consult(token).

% forms base URL to access guild by ID through Discord API
guild_URL(GuildID, GuildURL) :-
	string_concat("https://discordapp.com/api/guilds/", GuildID, GuildURL).

% forms URL to access channel by ID through Discord API
channel_URL(ChannelID, ChannelURL) :-
	string_concat("https://discordapp.com/api/channels/", ChannelID, ChannelURL).

% various endpoints for guilds can be found here: 
% https://discordapp.com/developers/docs/resources/guild

% forms URL to access guild roles
roles_URL(GuildID, RolesURL) :-
	guild_URL(GuildID, GuildURL),
	string_concat(GuildURL, "/roles", RolesURL).

% forms URL to access guild channels
channels_URL(GuildID, ChannelsURL) :-
	guild_URL(GuildID, GuildURL),
	string_concat(GuildURL, "/channels", ChannelsURL).

% forms URL to access guild members
members_URL(GuildID, MembersURL) :-
	guild_URL(GuildID, GuildURL),
	string_concat(GuildURL, "/members", MembersURL).

% forms URL to access individual guild member by user ID
member_URL(GuildID, UserID, MemberURL) :-
	members_URL(GuildID, MembersURL),
	string_concat(MembersURL, "/", URL),
	string_concat(URL, UserID, MemberURL).

% forms URL to access guild bans
bans_URL(GuildID, BansURL) :-
	guild_URL(GuildID, GuildURL),
	string_concat(GuildURL, "/bans", BansURL).

% forms URL to access guild voice regions
voice_regions_URL(GuildID, VoiceRegionsURL) :-
	guild_URL(GuildID, GuildURL),
	string_concat(GuildURL, "/regions", VoiceRegionsURL).

% forms URL to access guild invites
invites_URL(GuildID, InvitesURL) :-
	guild_URL(GuildID, GuildURL),
	string_concat(GuildURL, "/invites", InvitesURL).


% gets data as dict given URL
get_data(URL, Dict) :-
	bot_token(Token),
	catch(http_open(URL, Stream, [request_header("Authorization"=Token)]),
		error(Err, _),
		(format("Error while retrieving data:\n    ~w\nDoes bot have access to guild / Is guild ID correct?\n", [Err]),
		  fail)),
	json_read_dict(Stream, Dict).


% guilds are synonymous to servers - collection of users and channels
% e.g. ?- get_roles("6317111103203792896",X).

% gets guild as dict given guild ID
get_guild(GuildID, Dict) :-
	guild_URL(GuildID, URL),
	get_data(URL, Dict).

% gets roles as dict given guild ID
get_roles(GuildID, Dict) :-
	roles_URL(GuildID, URL),
	get_data(URL, Dict).

% gets channels as dict given guild ID
get_channels(GuildID, Dict) :-
	channels_URL(GuildID, URL),
	get_data(URL, Dict).

% gets individual channel as dict given channel ID
get_channel(ChannelID, Dict) :-
	channel_URL(ChannelID, URL),
	get_data(URL, Dict).

% gets members as dict given guild ID
get_members(GuildID, Dict) :-
	members_URL(GuildID, URL),
	get_data(URL, Dict).

% gets individual member as dict given guild ID and user ID
get_member(GuildID, UserID, Dict) :-
	member_URL(GuildID, UserID, URL),
	get_data(URL, Dict).

% gets bans as dict given guild ID
get_bans(GuildID, Dict) :-
	bans_URL(GuildID, URL),
	get_data(URL, Dict).

% gets voice regions as dict given guild ID
get_voice_regions(GuildID, Dict) :-
	voice_regions_URL(GuildID, URL),
	get_data(URL, Dict).

% gets invites as dict given guild ID
get_invites(GuildID, Dict) :-
	invites_URL(GuildID, URL),
	get_data(URL, Dict).
	
	

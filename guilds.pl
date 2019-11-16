:- use_module(library(http/http_open)).
:- use_module(library(http/json)).

% gets bot_token("Bot {token}").
% associated bot must be a member of the guild whose data is requested
% token.pl is intentionally not pushed to remote repo to protect tokens
:- consult(token).

% forms URL to access guild by ID through Discord API
guild_URL(GuildID, GuildURL) :-
	string_concat("https://discordapp.com/api/guilds/", GuildID, GuildURL).

% forms URL to access guild roles
roles_URL(GuildID, RolesURL) :-
	guild_URL(GuildID, GuildURL),
	string_concat(GuildURL, "/roles", RolesURL).

% forms URL to access guild channels
channels_URL(GuildID, ChannelsURL) :-
	guild_URL(GuildID, GuildURL),
	string_concat(GuildURL, "/channels", ChannelsURL).

% gets data as dict given URL
get_data(URL, Dict) :-
	bot_token(Token),
	catch(http_open(URL, Stream, [request_header("Authorization"=Token)]),
		error(Err, _),
		(format("Error while retrieving data:\n    ~w\nDoes bot have access to guild / Is guild ID correct?\n", [Err]),
		  fail)),
	json_read_dict(Stream, Dict, [tag(id)]).

get_roles(GuildID, Dict) :-
	roles_URL(GuildID, URL),
	get_data(URL, Dict).

get_channels(GuildID, Dict) :-
	channels_URL(GuildID, URL),
	get_data(URL, Dict).

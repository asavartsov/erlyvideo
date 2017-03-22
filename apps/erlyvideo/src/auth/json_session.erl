%%---------------------------------------------------------------------------------------
%%% @author     Max Lapshin <max@maxidoors.ru> [http://erlyvideo.org]
%%% @copyright  2010 Max Lapshin
%%% @doc        JSON session.
%%% @reference  See <a href="http://erlyvideo.org/authorization" target="_top">http://erlyvideo.org/authorization</a> for more information
%%% @end
%%%
%%% This file is part of erlyvideo.
%%% 
%%% erlyvideo is free software: you can redistribute it and/or modify
%%% it under the terms of the GNU General Public License as published by
%%% the Free Software Foundation, either version 3 of the License, or
%%% (at your option) any later version.
%%%
%%% erlyvideo is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%% GNU General Public License for more details.
%%%
%%% You should have received a copy of the GNU General Public License
%%% along with erlyvideo.  If not, see <http://www.gnu.org/licenses/>.
%%%
%%%---------------------------------------------------------------------------------------
-module(json_session).
-author('Max Lapshin <max@maxidoors.ru>').
-include_lib("../../../rtmp/include/rtmp.hrl").
-include("../log.hrl").
-export([connect/2, auth/3]).


auth(Host, _Method, LoginInfo) ->
  Secret = ems:get_var(secret_key, Host, undefined),
  rtmp_cookie:decode(LoginInfo, Secret).
  

connect(State, AMF) ->
  Host = rtmp_session:get(State, host),
  Address = rtmp_session:get(State, addr),
  PlayerInfo = rtmp_session:get(State, player_info),
  undefined = rtmp_session:get(State, user_id),
  
  State1 = rtmp_cookie:connect(State, AMF),
  
  case rtmp_session:get(State1, user_id) of
    undefined ->
	    ems_log:access(Host, "REJECT ~s ~s ~p ~p ~s json_session", [Address, Host, undefined, undefined, proplists:get_value(pageUrl, PlayerInfo)]),
      rtmp_session:reject_connection(State1);
	  UserId ->
	    SessionId = rtmp_session:get(State1, session_id),
    	ems_log:access(Host, "CONNECT ~s ~s ~p ~p ~s json_session", [Address, Host, UserId, SessionId, proplists:get_value(pageUrl, PlayerInfo)]),
      rtmp_session:accept_connection(State1)
  end.



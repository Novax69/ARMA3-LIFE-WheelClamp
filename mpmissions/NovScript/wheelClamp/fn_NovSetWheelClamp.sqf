#include "..\..\script_macros.hpp"
/*
    File: fn_NovSetWheelClamp.sqf
    Author: Novax
   	github : https://github.com/Novax69 <== Find my other scripts for arma here
    Date : 17/01/2022

    Description:
		Add or Remove a wheelclamp.

*/


private["_vehicle","_waitingTime","_animation","_ui","_progress","_pgText","_cP","_totalTime"];
if(isNull cursorTarget) exitWith {hint localize "STR_NOV_WClamp_NoVehicle"};

_vehicle = cursorTarget;
_totalTime = NOV_PARAMS(getNumber,"nov_timeToPlaceOrRemove"); // Secondes
_waitingTime = 0; 

//Setup our progress bar.
disableSerialization;
"progressBar" cutRsc ["life_progress","PLAIN"];
_ui = uiNamespace getVariable "life_progress";
_progress = _ui displayCtrl 38201;
_pgText = _ui displayCtrl 38202;
_progress progressSetPosition 0.01;
_pgText ctrlSetText format [localize "STR_NOV_WClamp_Loading"];
_cP = 0.01;


_animation = {
	private _mode = _this select 0;
	private _text = "";
	switch (_mode) do {
		case 0: { _text = localize "STR_NOV_WClamp_PlaceWheelClamp";};
		case 1: { _text = localize "STR_NOV_WClamp_RemoveWheelClamp";};
	};

	while { alive player && alive _vehicle && player distance _vehicle < 5 && _waitingTime <= _totalTime} do {
		_waitingTime = round(_waitingTime + 1);
		player playActionNow "medicstartup";
		sleep 1;
		_cP = (((_waitingTime * 100)/_totalTime)/100);
		_progress progressSetPosition _cP;
		_pgText ctrlSetText format ["%3 (%1%2)",round(_cP * 100),"%",_text];
		if(_cP >= 1) exitWith {};
	};
	if (_waitingTime > 0 && player distance _vehicle > 5) then {
		["NovInfoMessage",[localize "STR_NOV_WClamp_InfoNotif","NovScript\NovTextures\wheelClamp.paa",localize "STR_NOV_WClamp_Cancelled"]] call BIS_fnc_showNotification;

	};
};

if (isNil {_vehicle getvariable "Nov_vehicleIsClamped"}) then {
	[0] call _animation;
	if(_waitingTime > _totalTime ) exitWith {};
    "progressBar" cutText ["","PLAIN"];
	_vehicle setVariable["Nov_vehicleIsClamped",1,true];
	[_vehicle,2] remoteExecCall ["life_fnc_lockVehicle",_vehicle];
	["NovInfoMessage",[localize "STR_NOV_WClamp_InfoNotif","NovScript\NovTextures\wheelClamp.paa",localize "STR_NOV_WClamp_Placed"]] call BIS_fnc_showNotification;

} else {
	[1] call _animation;
	if (_waitingTime > _totalTime) exitWith {};
    "progressBar" cutText ["","PLAIN"];
	_vehicle setVariable["Nov_vehicleIsClamped",nil,true];
	["NovInfoMessage",[localize "STR_NOV_WClamp_InfoNotif","NovScript\NovTextures\wheelClamp.paa",localize "STR_NOV_WClamp_Removed"]] call BIS_fnc_showNotification;
};

player switchmove ""; // Stop animation
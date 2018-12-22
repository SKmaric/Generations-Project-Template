-- Sonic Generations QuickBoot script by Xanvier / xan1242 --
-- SE fix by SKmaric --
-- Version 1.2 --

-- Made to ease modding and speedrunning.
-- I'm planning to put sequential stages as well as customizable sequences and more flexibility (such as not being limited to PlayerClass, rather to load the default one or force it on load by your choice).
-- This script can *technically* be used to add stages to the game, however, it is severely broken if you do.
-- If there are any bugs, please report them to me via YouTube or Steam (xan1242 on YouTube, Xanvier on Steam) with steps to reproduce the bug(s).
-- Before you report any bugs, please test it out multiple times as the game itself with cpkredir is unstable.
-- If you are going to include this in your mod or use this script as a basis, you do not need to ask for permission, however, it would be nice to leave a credit. :)

-- DEFAULT VALUES: "ghz200", 0, 0, 0, 0, 0, 1, 0, 0

-- グローバル変数 -- Global variables
global("StageName", "ghz200"); -- Set the quick boot stage here.
global("StageMission", 0); -- Set the mission here.
global("PlayerClass", 0); -- Set the type of Sonic here
						  -- 0 - Generic Sonic / Modern Sonic
						  -- 1 - Classic Sonic
						  -- 2 - BLB Super Sonic / Final Boss Super Sonic (WARNING - Unstable, do not touch any objects and do not switch Sonics)
global("ForcePlayerClassOnRestart", 0); -- Only used when QuickBoot mode is 0 or 1. Enable this to override the PlayerClass (self.player) value set by StorySequence 
										-- on reload in normal game mode. The reload must be set with ExitType.
										-- 0 - Off
										-- 1 - On
global("ForcePlayerClassOnGoalReach", 0); -- Set the PlayerClass override for finishing the stage, valid are the same values and rules as above.

global("g_IsDebugSequence", 0);	-- デバッグシーケンスフラグ -- Missing Gindows, do not enable debug mode as it does nothing and causes the game to hang

global("g_IsQuickBoot", 3); -- 	   Set the type of quick game booting here.
							-- 0 - Normal
							-- 1 - Directly to the title screen (also this and the latter ones fix the missing sound effects, such as quickstep, recommended for most people)
							-- 2 - Directly to a stage from the title screen (on exit it returns you to PlayableMenu, unless otherwise specified)
							-- 3 - Directly to a stage (does not load the save file, does not load Application.prm.xml and there is no sound during 
							--	   the loading screen, useful for stage testing, on exit it returns you to the title, unless otherwise specified)

global("ExitType", 2); -- Set the exit type you wish here
					   -- 0 - Normal (title or PlayableMenu)
					   -- 1 - Exit from the game completely
					   -- 2 - Reload the stage (for testing and speedrunning it is VERY useful)
					   -- 3 - Load another stage using the StageName variable (use this if you want to load a secondary stage, not useful in QuickBoot modes 2 and 3)

global("ExitTypeOnGoalReach", 0) -- Set the exit type when you finish the stage, valid are the same values as above

-- COMPATIBILITY VARIABLES FOR UNLEASHED PROJECT (because it's always Dario's fault, ask TGE why) --
SONICGMI_STAGE_BOOT = g_IsQuickBoot
SONICGMI_SONIC = PlayerClass
SONICGMI_STAGE_NAME = StageName
SONICGMI_STAGE_MISSION = StageMission

-- WARNING --
-- Without any basic knowledge of programming, DO NOT edit the code below UNLESS you are absolutely sure you know what you're doing.
-- Bad code will cause game to either crash, freeze or even hang some running code.
-- If editing, before doing so BACKUP YOUR SAVE GAME if you haven't already.

-- モード
global("MODULE_INIT",			"AppInit");
global("MODULE_LOGO",			"Logo");
global("MODULE_TITLE",			"Title");
global("MODULE_STORY",			"Story");
global("MODULE_MENU",			"Menu");
global("MODULE_DEBUGMENU",		"DebugMenu");
global("MODULE_PLAYABLEMENU",	"PlayableMenu");
global("MODULE_STAGE",			"Stage");
global("MODULE_EVENT",			"Event");
global("MODULE_STAGEEVENT",		"StageEvent");
global("MODULE_STAFFROLL",		"StaffRoll");
global("MODULE_EXIT",			"AppExit");
global("MODULE_GENESIS",		"Genesis");
global("MODULE_ONLINESTAGE",	"OnlineStage");
global("MODULE_SAVE",			"Save");
global("MODULE_NOTICEBOARD",	"NoticeBoard");
global("MODULE_NOTICE_SONICT",	"NoticeSonicT");	-- ソニックチーム
global("MODULE_NOTICE_ESRB",	"NoticeEsrb");		-- ESRBレイティング表示
global("MODULE_NOTICE_STEREO",	"NoticeStereo");	-- 立体視警告
global("MODULE_NOTICE_TEASER",	"NoticeTeaser");	-- ティザームービー
global("MODULE_STATUE",			"Statue");			-- スタチュー部屋
global("MODULE_DEBUGINIT",		"DebugInit");		-- デバッグシーケンス用初期化
global("MODULE_SUPERSONIC",		"SuperSonic");		-- スーパーソニック
global("MODULE_NOTICE_HAVOK",	"NoticeHavok");		-- Havok&Dolby
global("MODULE_NOTICE_CESA",	"NoticeCesa");		-- CESA警告

local s_Sequence = nil

-- シーケンス起動
function createSequenceActor()
	-- MainSequence作成
	s_Sequence = MainSequence:new()
end

-- シーケンス終了
function destroySequenceActor()
	if s_Sequence ~= nil then
		-- MainSequence削除
		g_Scheduler:delete_actor(s_Sequence)
	end
end

function getNextModule()
	local module = GetNextModule()

	if module == "Logo" then
		return MODULE_LOGO
	elseif module == "PlayableMenu" then
		return MODULE_PLAYABLEMENU
	elseif module == "Title" then
		return MODULE_TITLE
	elseif module == "Story" then
		return MODULE_STORY
	elseif module == "Menu" then
		return MODULE_MENU
	elseif module == "Stage" then
		return MODULE_STAGE
	elseif module == "Event" then
		return MODULE_EVENT
	elseif module == "StageEvent" then
		return MODULE_STAGEEVENT
	elseif module == "StaffRoll" then
		return MODULE_STAFFROLL
	elseif module == "Genesis" then
		return MODULE_GENESIS
	elseif module == "OnlineStage" then
		return MODULE_ONLINESTAGE
	elseif module == "NoticeSonicT" then
		return MODULE_NOTICE_SONICT
	elseif module == "NoticeEsrb" then
		return MODULE_NOTICE_ESRB
	elseif module == "NoticeStereo" then
		return MODULE_NOTICE_STEREO
	elseif module == "Statue" then
		return MODULE_STATUE
	elseif module == "DebugInit" then
		return MODULE_DEBUGINIT
	elseif module == "Save" then
		return MODULE_SAVE
	else
		return nil
	end
end

--[[
	MainSequence Class
]]
subclass ("MainSequence", Actor) {
	__tostring = function()
		return("MainSequence")
	end
}

function MainSequence:ctor(...)
	MainSequence.super.ctor(self, ...)

	-- シーケンステーブル作成
	self.sequence_table = {}
	local seqtbl = self.sequence_table

	-- シーケンス登録
	seqtbl[MODULE_INIT] = SequenceInit:new(self)
	seqtbl[MODULE_LOGO] = SequenceLogo:new(self)
	seqtbl[MODULE_TITLE] = SequenceTitle:new(self)
	seqtbl[MODULE_STORY] = SequenceStory:new(self)
	seqtbl[MODULE_MENU] = SequenceMenu:new(self)
	seqtbl[MODULE_DEBUGMENU] = SequenceDebugMenu:new(self)
	seqtbl[MODULE_PLAYABLEMENU] = SequencePlayableMenu:new(self)
	seqtbl[MODULE_STAGE] = SequenceStage:new(self)
	seqtbl[MODULE_EVENT] = SequenceEvent:new(self)
	seqtbl[MODULE_STAGEEVENT] = SequenceStageEvent:new(self)
	seqtbl[MODULE_STAFFROLL] = SequenceStaffRoll:new(self)
	seqtbl[MODULE_EXIT] = SequenceExit:new(self)
	seqtbl[MODULE_GENESIS] = SequenceGenesis:new(self)
	seqtbl[MODULE_ONLINESTAGE] = SequenceOnlineStage:new(self)
	seqtbl[MODULE_SAVE] = SequenceSave:new(self)
	seqtbl[MODULE_NOTICE_SONICT] = SequenceNoticeBoard:new(self, 3, true, false, false, false, "ui_nb_sonicteam", 2.0, MODULE_NOTICE_HAVOK, MODULE_NOTICE_HAVOK)
	seqtbl[MODULE_NOTICE_ESRB] = SequenceNoticeESRB:new(self)
	seqtbl[MODULE_NOTICE_STEREO] = SequenceNoticeStereo:new(self)
	seqtbl[MODULE_NOTICE_TEASER] = SequenceNoticeTeaser:new(self)
	seqtbl[MODULE_STATUE] = SequenceStatue:new(self)
	seqtbl[MODULE_DEBUGINIT] = SequenceDebugInit:new(self)
	seqtbl[MODULE_SUPERSONIC] = SequenceNoticeBoard:new(self, 3, true, true, false, false, "ui_nb_super_sonic", 5.0, MODULE_SAVE, MODULE_SAVE)
	seqtbl[MODULE_NOTICE_HAVOK] = SequenceNoticeHavok:new(self)
	seqtbl[MODULE_NOTICE_CESA] = SequenceNoticeCesa:new(self)

	-- モード設定
	self.module = MODULE_INIT
	self.prev_module = MODULE_INIT
	seqtbl[self.module]:initialize()
end

function MainSequence:update(act)
	local smodule = self.module
	local seqtbl = self.sequence_table

	local ret = seqtbl[smodule]:execute()

	-- ゲームをやめたとき(ソフトリセット？)
	local is_quit = IsQuitGame()
	if is_quit == 1 then
		self.module = MODULE_TITLE;	-- タイトルへ移行
		seqtbl[self.module]:initialize()
		return true
	end

	if ret == "Exit" then
		s_Sequence = nil
		return false	-- Actor exit
	elseif ret == nil then
		PringString("MainSequence: Don't set next module.")
	else
		-- 返り値のモードへ変更
		self.prev_module = self.module
		self.module = ret
		seqtbl[ret]:initialize()
	end

	return true	-- Actor continue
end

function MainSequence:getPrevModule()
	return self.prev_module
end


--[[
	SequenceBase Class
]]
class ("SequenceBase") {
	__tostring = function(self)
		return("Sequence Module "..self.module_name)
	end
}

function SequenceBase:ctor(...)
	local t = {...}

	self.manager = t[1]
end

function SequenceBase:initialize()
end

function SequenceBase:execute()
end


--[[
	SequenceInit Class
]]
subclass ("SequenceInit", SequenceBase) {
}

function SequenceInit:ctor(...)
	SequenceInit.super.ctor(self, ...)

	self.module_name = MODULE_INIT
end

function SequenceInit:initialize()
	StartModule( self.module_name );
end

function SequenceInit:execute()
	-- ストーリーシーケンススクリプトロード
	LoadScript("StorySequence");
	LoadScript("StorySequenceUtility");
	Actor:wait_step( WaitEndModule )
	
	return MODULE_DEBUGINIT  -- DEBUGINIT was used to prevent missing sound effects.
end


--[[
	SequenceLogo Class
]]
subclass ("SequenceLogo", SequenceBase) {
}

function SequenceLogo:ctor(...)
	SequenceLogo.super.ctor(self, ...)

	local t = {...};

	self.module_name = MODULE_LOGO
	self.notice_type = 2		-- 0:Logo20  1:Splash  2:Movie  3:NoticeBoard
	self.notice_flag = 0		
	self.data_name = nil
end

function SequenceLogo:initialize()
	StartModule( MODULE_NOTICEBOARD )
	if g_IsQuickBoot > 0 then
		SetNoticeBoardParam(self.notice_type, self.notice_flag, "null.sfd", 0.0, 0.0);
	else
		SetNoticeBoardParam(self.notice_type, self.notice_flag, "sega_logo_us.sfd", 0.0, 0.0);
	end
end

function SequenceLogo:execute()
	Actor:wait_step( WaitEndModule )
	if g_IsQuickBoot == 1 or g_IsQuickBoot == 2 then
		return MODULE_TITLE;
	elseif g_IsQuickBoot == 3 then
		SetupPlayerForce(PlayerClass);
		SetupStage(StageName, StageMission);
		return MODULE_STAGE;
	else
		return MODULE_NOTICE_SONICT
	end
end


--[[
	SequenceTitle Class
]]
subclass ("SequenceTitle", SequenceBase) {
}

function SequenceTitle:ctor(...)
	SequenceTitle.super.ctor(...)

	self.module_name = MODULE_TITLE
end

function SequenceTitle:initialize()
	StartModule( self.module_name )
	-- ・ｽt・ｽ@・ｽC・ｽ・ｽ・ｽ・ｽ・ｽ[・ｽh・ｽ・ｽ・ｽN・ｽG・ｽX・ｽg
--	LoadArchive(self.data_name, self.arch_name)

	-- ・ｽX・ｽg・ｽ[・ｽ・ｽ・ｽ[・ｽV・ｽ[・ｽP・ｽ・ｽ・ｽX・ｽ尞・
	DestroyStory();
end

function SequenceTitle:execute()
--	Actor:wait_step( WaitLoading, {self.data_name} )
	Actor:wait_step( WaitEndModule )
--	UnloadArchive( self.data_name )

	local module = getNextModule();

	if module ~= nil then
		return module;
	else
		local ret = GetEndState()

		if ret == 2 then
			-- ・ｽI・ｽ・ｽ・ｽ・ｽ・ｽC・ｽ・ｽ
			return MODULE_ONLINESTAGE;
		elseif ret == 1 then
			-- ・ｽ・ｽ・ｽ[・ｽr・ｽ[
			return MODULE_NOTICE_TEASER;
		else
			if g_IsQuickBoot == 2 then			-- Condition for QuickBoot mode 2 obviously
				SetupPlayerForce(PlayerClass);
				SetupStage(StageName, StageMission);
				return MODULE_STAGE;
			else
				return MODULE_STORY;
			end
		end
	end
end


--[[
	SequenceStory Class
]]
subclass ("SequenceStory", SequenceBase) {
}

function SequenceStory:ctor(...)
	SequenceStory.super.ctor(self, ...);

	self.module_name = MODULE_STORY;
	self.prev_module = nil;
end

function SequenceStory:initialize()
	PrintString("Sequence Story Start");
--	StartModule( self.module_name );	-- StartModuleしなければアプリケーション側にモードを用意する必要ない

	-- ストーリーシーケンス開始
	StartStory();
end

function SequenceStory:execute()
	Actor:wait_step( WaitSkipStory );

	PrintString("Sequence Story End");
	return storyGetNextModuleFromTitle();
end


--[[
	SequenceMenu Class
]]
subclass ("SequenceMenu", SequenceBase) {
}

function SequenceMenu:ctor(...)
	SequenceMenu.super.ctor(self, ...);

	self.module_name = MODULE_MENU;
end

function SequenceMenu:initialize()
	PrintString("Sequence Menu Start");
--	StartModule( self.module_name )	-- StartModuleしなければアプリケーション側にモードを用意する必要ない
end

function SequenceMenu:execute()
	PrintString("Sequence Menu End");
	storySetNextPam();
	return MODULE_PLAYABLEMENU;
end


--[[
	SequenceDebugMenu Class
]]
subclass ("SequenceDebugMenu", SequenceBase) {
}

function SequenceDebugMenu:ctor(...)
	SequenceDebugMenu.super.ctor(self, ...);

	self.module_name = MODULE_DEBUGMENU;
end

function SequenceDebugMenu:initialize()
	StartModule( self.module_name );
end

function SequenceDebugMenu:execute()
	Actor:wait_step( WaitEndModule );

	local ret = GetEndState();

	if ret == 0 then
		local module = getNextModule();
		if module == nil then
			return MODULE_STAGE;
		else
			return module;
		end
	else
		return MODULE_TITLE;
	end
end


--[[
	SequencePlayableMenu Class
]]
subclass ("SequencePlayableMenu", SequenceBase) {
}

function SequencePlayableMenu:ctor(...)
	SequencePlayableMenu.super.ctor(self, ...);

	self.module_name = MODULE_PLAYABLEMENU;
--	self.data_name = "pam000";
--	self.arch_name = "pam000.ar";
end

function SequencePlayableMenu:initialize()
	StartModule( self.module_name );
	-- ファイルロードリクエスト
--	LoadArchive(self.data_name, self.arch_name)
end

function SequencePlayableMenu:execute()
--	Actor:wait_step( WaitLoading, {self.data_name} )
	Actor:wait_step( WaitEndModule );
--	UnloadArchive( self.data_name )

	local ret = GetEndState();

	if ret == 0 then
		return storyGetNextModuleFromPam();
	else
		return MODULE_TITLE;
	end
end

StageNameLoad = ""

--[[
	SequenceStage Class
]]
subclass ("SequenceStage", SequenceBase) {
}

function SequenceStage:ctor(...)
	SequenceStage.super.ctor(self, ...)

	self.module_name = MODULE_STAGE;
	self.stage_name = nil;
end

function SequenceStage:initialize()
	StartModule( self.module_name );
	-- ステージ名取得
	self.stage_name = GetStageName();
--	local arch_name = self.stage_name .. ".ar";
	-- ファイルロードリクエスト
--	LoadArchive(self.stage_name, arch_name)
end

function SequenceStage:execute()
--	Actor:wait_step( WaitLoading, {self.stage_name} )
	Actor:wait_step( WaitEndModule );
--	UnloadArchive( self.stage_name )

	if g_IsDebugSequence == 0 then
		local ret = GetEndState();
		
		if StageNameLoad == "" and (ExitType == 2 or ExitTypeOnGoalReach == 2) then
			StageNameLoad = GetStageName();
		elseif ExitType == 3 or ExitTypeOnGoalReach == 3 then
			StageNameLoad = StageName
		end
		
		if ret == 0 then					-- Stage finish
			if ExitTypeOnGoalReach == 1 then
				return 0;
			elseif ExitTypeOnGoalReach == 2 or ExitTypeOnGoalReach == 3 then
				if ForcePlayerClassOnGoalReach == 1 and g_IsQuickBoot < 2 then
					SetupPlayerForce(PlayerClass);
				end
				SetupStage(StageNameLoad, StageMission);
				return MODULE_STAGE;
			else
				StageNameLoad = ""
				return storyGetNextModuleFromStage();
			end
		else
			if ExitType == 1 then			-- Anything other than stage finish (usually abort/quit)
				return 0;
			elseif ExitType == 2 or ExitType == 3 then
				if ForcePlayerClassOnRestart == 1 and g_IsQuickBoot < 2 then
					SetupPlayerForce(PlayerClass);
				end
				SetupStage(StageNameLoad, StageMission);
				return MODULE_STAGE;
			else
				StageNameLoad = ""
				return storyGetNextModuleFromStageAbort();
			end
		end
	else
		return MODULE_PLAYABLEMENU;
	end
end


--[[
	SequenceEvent Class
]]
subclass ("SequenceEvent", SequenceBase) {
}

function SequenceEvent:ctor(...)
	SequenceEvent.super.ctor(self, ...)

	self.module_name = MODULE_EVENT;
	self.event_name = nil;
end

function SequenceEvent:initialize()
	StartModule( self.module_name );
	-- イベント名取得
--	self.event_name = GetEventName()
	-- ファイルロードリクエスト
--	LoadArchive(self.stage_name, arch_name)
end

function SequenceEvent:execute()
--	Actor:wait_step( WaitLoading, {self.stage_name} )
	Actor:wait_step( WaitEndModule );
--	UnloadArchive( self.stage_name )

	local module = getNextModule();

	if module ~= nil then
		return module;
	end

	return storyGetNextModuleFromEvent();
end


--[[
	SequenceStageEvent Class
]]
subclass ("SequenceStageEvent", SequenceBase) {
}

function SequenceStageEvent:ctor(...)
	SequenceStageEvent.super.ctor(self, ...)

	self.module_name = MODULE_STAGEEVENT;
	self.stage_name = nil;

	self.from_event_module = false;
end

function SequenceStageEvent:initialize()
	StartModule( self.module_name );

	if s_Sequence.prev_module == MODULE_EVENT then
		self.from_event_module = true;
	end
	-- ステージ名取得
--	self.stage_name = GetStageName();
--	local arch_name = self.stage_name .. ".ar";
	-- ファイルロードリクエスト
--	LoadArchive(self.stage_name, arch_name)
end

function SequenceStageEvent:execute()
--	Actor:wait_step( WaitLoading, {self.stage_name} )
	Actor:wait_step( WaitEndModule );
--	UnloadArchive( self.stage_name )

	if self.from_event_module then
		return MODULE_EVENT;
	else
		return MODULE_MENU;
	end
end


--[[
	SequenceStaffRoll Class
]]
subclass ("SequenceStaffRoll", SequenceBase) {
}

function SequenceStaffRoll:ctor(...)
	SequenceStaffRoll.super.ctor(self, ...)

	self.module_name = MODULE_STAFFROLL;
end

function SequenceStaffRoll:initialize()
	StartModule( self.module_name );
end

function SequenceStaffRoll:execute()
	Actor:wait_step( WaitEndModule );

	local ret = GetEndState();

	if ret == 0 then
		return storyGetNextModuleFromStaffRoll();
	else
		-- Abort
		return MODULE_TITLE;
	end
end


--[[
	SequenceExit Class
]]
subclass ("SequenceExit", SequenceBase) {
}

function SequenceExit:ctor(...)
	SequenceExit.super.ctor(self, ...)

	self.module_name = MODULE_EXIT
end

function SequenceExit:initialize()
	StartModule( self.module_name )
end

function SequenceExit:execute()
	return 0;
end


--[[
	SequenceGenesis Class -- Broken menu, emulator code probably missing or simply ROM of Sonic 1 is missing.
]]
subclass ("SequenceGenesis", SequenceBase) {
}

function SequenceGenesis:ctor(...)
	SequenceGenesis.super.ctor(self, ...)

	self.module_name = MODULE_GENESIS
end

function SequenceGenesis:initialize()
	StartModule( self.module_name )
end

function SequenceGenesis:execute()
	Actor:wait_step( WaitEndModule )

	local ret = GetEndState();

	if ret == 0 then
		return MODULE_MENU;
	else
		-- Abort
		return MODULE_TITLE;
	end
end


--[[
	SequenceOnlineStage Class
]]
subclass ("SequenceOnlineStage", SequenceBase) {
}

function SequenceOnlineStage:ctor(...)
	SequenceOnlineStage.super.ctor(self, ...)

	self.module_name = MODULE_ONLINESTAGE
end

function SequenceOnlineStage:initialize()
	StartModule( self.module_name )
end

function SequenceOnlineStage:execute()
	Actor:wait_step( WaitEndModule )

	return MODULE_TITLE;
end


--[[
	SequenceSave Class
]]
subclass ("SequenceSave", SequenceBase) {
}

function SequenceSave:ctor(...)
	SequenceSave.super.ctor(self, ...)

	self.module_name = MODULE_SAVE
end

function SequenceSave:initialize()
	StartModule( self.module_name )
end

function SequenceSave:execute()
	Actor:wait_step( WaitEndModule )

	-- ストーリー終了時のセーブ後はタイトルへ
	return MODULE_TITLE;
end


--[[
	SequenceNoticeBoard Class
]]
subclass ("SequenceNoticeBoard", SequenceBase) {
}

function SequenceNoticeBoard:ctor(...)
	SequenceNoticeBoard.super.ctor(self, ...)

	local t = {...};	-- 要素1はマネージャなので2から使用する

	self.module_name = MODULE_NOTICEBOARD
	self.notice_type = t[2]		-- 0:Logo20  1:Splash  2:Movie  3:NoticeBoard
	self.notice_flag = 0
	if t[3] == true then	-- Enable Skip
		self.notice_flag = self.notice_flag + 1
	end
	if t[4] == true then	-- Show Guide Button
		self.notice_flag = self.notice_flag + 2
	end
	if t[5] == true then	-- Enter BG White
		self.notice_flag = self.notice_flag + 4
	end
	if t[6] == true then	-- Leave BG White
		self.notice_flag = self.notice_flag + 8
	end
	self.data_name = t[7]
	self.disp_time = t[8]

	self.next_module0 = t[9]
	self.next_module1 = t[10]

	self.force_time = 0.0
end

function SequenceNoticeBoard:initialize()
	StartModule( MODULE_NOTICEBOARD )

	SetNoticeBoardParam(self.notice_type, self.notice_flag, self.data_name, self.disp_time, self.force_time);
end

function SequenceNoticeBoard:execute()
	Actor:wait_step( WaitEndModule )

	local ret = GetEndState();

	if ret == 0 then
		return self.next_module0;
	else
		return self.next_module1;
	end
end


--[[
	SequenceNoticeESRB Class
]]
subclass ("SequenceNoticeESRB", SequenceBase) {
}

function SequenceNoticeESRB:ctor(...)
	SequenceNoticeESRB.super.ctor(self, ...)

	local t = {...};

	self.module_name = MODULE_NOTICE_ESRB
	self.notice_type = 3		-- 0:Logo20  1:Splash  2:Movie  3:NoticeESRB
	self.notice_flag = 0
	self.data_name = "ui_nb_esrb"
	self.disp_time = 4.0
	self.force_time = 0.0
	self.show = 0
end

function SequenceNoticeESRB:initialize()
	self.show = DoShowESRB()
	if self.show == 1 then
		StartModule( MODULE_NOTICEBOARD )

		SetNoticeBoardParam(self.notice_type, self.notice_flag, self.data_name, self.disp_time, self.force_time);
	end
end

function SequenceNoticeESRB:execute()
	if self.show == 1 then
		Actor:wait_step( WaitEndModule )
	end

	return MODULE_TITLE;
end


--[[
	SequenceNoticeStereo Class
]]
subclass ("SequenceNoticeStereo", SequenceBase) {
}

function SequenceNoticeStereo:ctor(...)
	SequenceNoticeStereo.super.ctor(self, ...)

	local t = {...};

	self.module_name = MODULE_NOTICE_STEREO
	self.notice_type = 3		-- 0:Logo20  1:Splash  2:Movie  3:NoticeStereo
	self.notice_flag = 1		-- Enable Skip
	self.data_name = "ui_nb_3DArart"
	self.disp_time = 4.0
	self.force_time = 0.0
	self.show = 0
end

function SequenceNoticeStereo:initialize()
	self.show = DoShowNotice3D()
	if self.show == 1 then
		StartModule( MODULE_NOTICEBOARD )

		SetNoticeBoardParam(self.notice_type, self.notice_flag, self.data_name, self.disp_time, self.force_time);
	end
end

function SequenceNoticeStereo:execute()
	if self.show == 1 then
		Actor:wait_step( WaitEndModule )
	end

	return MODULE_LOGO;
end


--[[
	SequenceNoticeTeaser Class
]]
subclass ("SequenceNoticeTeaser", SequenceBase) {
}

function SequenceNoticeTeaser:ctor(...)
	SequenceNoticeTeaser.super.ctor(self, ...)

	local t = {...};

	self.module_name = MODULE_NOTICE_TEASER
	self.notice_type = 2		-- 0:Logo20  1:Splash  2:Movie  3:NoticeBoard
	self.notice_flag = 9		-- Skip & Leave White
	self.data_name = nil
end

function SequenceNoticeTeaser:initialize()
	StartModule( MODULE_NOTICEBOARD )
	SetNoticeBoardParam(self.notice_type, self.notice_flag, "anniv_teaser.sfd", 0.0, 0.0);
end

function SequenceNoticeTeaser:execute()
	Actor:wait_step( WaitEndModule )

	return MODULE_TITLE;
end


--[[
	SequenceStatue Class
]]
subclass ("SequenceStatue", SequenceBase) {
}

function SequenceStatue:ctor(...)
	SequenceStatue.super.ctor(self, ...);

	self.module_name = MODULE_STATUE;
end

function SequenceStatue:initialize()
	StartModule( self.module_name );
end

function SequenceStatue:execute()
	Actor:wait_step( WaitEndModule );

	if g_IsDebugSequence == 0 then
		local ret = GetEndState();

		if ret == 0 then
			return MODULE_PLAYABLEMENU;
		else
			return MODULE_TITLE;
		end
	else
		return MODULE_DEBUGMENU;
	end
end


--[[
	SequenceDebugInit Class
]]
subclass ("SequenceDebugInit", SequenceBase) {
}

function SequenceDebugInit:ctor(...)
	SequenceDebugInit.super.ctor(self, ...);

	self.module_name = MODULE_DEBUGINIT;
end

function SequenceDebugInit:initialize()
	StartModule( self.module_name );
end

function SequenceDebugInit:execute()
	Actor:wait_step( WaitEndModule );
	return MODULE_NOTICE_CESA;
end


--[[
	SequenceNoticeHavok Class
]]
subclass ("SequenceNoticeHavok", SequenceBase) {
}

function SequenceNoticeHavok:ctor(...)
	SequenceNoticeHavok.super.ctor(self, ...)

	local t = {...};

	self.module_name = MODULE_NOTICE_HAVOK
	self.notice_type = 3		-- 0:Logo20  1:Splash  2:Movie  3:NoticeBoard
	self.notice_flag = 0
	self.data_name = "ui_nb_havok"
	self.disp_time = 2.0
	self.force_time = 0.0
	self.show = 0
end

function SequenceNoticeHavok:initialize()
	self.show = DoShowHavok()
	if self.show == 1 then
		StartModule( MODULE_NOTICEBOARD )

		SetNoticeBoardParam(self.notice_type, self.notice_flag, self.data_name, self.disp_time, self.force_time);
	end
end

function SequenceNoticeHavok:execute()
	if self.show == 1 then
		Actor:wait_step( WaitEndModule )
	end

	return MODULE_NOTICE_ESRB;
end


--[[
	SequenceNoticeCesa Class
]]
subclass ("SequenceNoticeCesa", SequenceBase) {
}

function SequenceNoticeCesa:ctor(...)
	SequenceNoticeCesa.super.ctor(self, ...)

	local t = {...};

	self.module_name = MODULE_NOTICE_CESA
	self.notice_type = 3		-- 0:Logo20  1:Splash  2:Movie  3:NoticeBoard
	self.notice_flag = 1		-- Enable Skip
	self.data_name = "ui_nb_cesa"
	self.disp_time = 5.0
	self.show = 0

	local ps3 = IsTargetPS3()
	if ps3 == 1 then
		self.force_time = 2.0
	else
		self.force_time = 0.0
	end
end

function SequenceNoticeCesa:initialize()
	self.show = DoShowCesa()
	if self.show == 1 then
		StartModule( MODULE_NOTICEBOARD )

		SetNoticeBoardParam(self.notice_type, self.notice_flag, self.data_name, self.disp_time, self.force_time);
	end
end

function SequenceNoticeCesa:execute()
	if self.show == 1 then
		Actor:wait_step( WaitEndModule )
	end

	return MODULE_NOTICE_STEREO;
end
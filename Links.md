# Links for Documentation
https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_ClassTalentUI/Blizzard_ClassTalentTalentsTab.lua#L1465
https://wowpedia.fandom.com/wiki/Dragonflight_Talent_System
https://wowpedia.fandom.com/wiki/API_C_ClassTalents.RequestNewConfig
https://github.com/Gethe/wow-ui-source/blob/d306d7354ad1f1d0ac118ec6a4dfc14746c04720/Interface/AddOns/Blizzard_APIDocumentationGenerated/SharedTraitsDocumentation.lua#L5


## Other info
C_ClassTalents.GetLastSelectedSavedConfigID(PlayerUtil.GetCurrentSpecID()) -> Seems to be last selected ID ?


## Info importante
C_ClassTalents.RequestNewConfig(name) -> Crea un nuevo perfil de talentos en blizzard que esta vacio, devvuelve true si se crea bien y false si no.


## Errores
1x SwitchSwitch/Frames/Main/MainFrame.lua:89: attempt to call method 'SetMinResize' (a nil value)
[string "@SwitchSwitch/Frames/Main/MainFrame.lua"]:89: in function `GetMainFrame'
[string "@SwitchSwitch/Frames/Main/MainFrame.lua"]:161: in function `ShowMainFrame'
[string "@SwitchSwitch/Frames/Main/MainFrame.lua"]:193: in function `TogleMainFrame'
[string "@SwitchSwitch/MinimapIcon.lua"]:53: in function `OnClick'
[string "@BugSack/Libs/LibDBIcon-1.0-52/LibDBIcon-1.0.lua"]:170: in function <BugSack/Libs/LibDBIcon-1.0/LibDBIcon-1.0.lua:168>

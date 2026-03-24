local ADDON_NAME = ...

local CONFIG = {
  frame = {
    width = 628, -- 宏窗口总宽度，包含左右面板和中间留白
    height = 655, -- 宏窗口总高度
  },

  leftPanel = {
    columns = 7, -- 左侧宏图标列表每行显示数量
    width = 360, -- 左侧面板宽度
    height = 560, -- 左侧面板高度
    offsetX = 18, -- 左侧面板相对 MacroFrame 左边缘的偏移
    offsetY = -58, -- 左侧面板相对 MacroFrame 顶部的偏移
    inset = 8, -- 左侧面板背景相对内容区域的包边
  },

  rightPanel = {
    width = 250, -- 右侧编辑面板宽度
    height = 220, -- 右侧编辑面板高度
    gap = 24, -- 左右面板之间的视觉间距
    topOffsetY = -132, -- 右侧文本区域顶部偏移
    selectedOffsetY = -60, -- 右侧选中宏区域顶部偏移
    scrollFrameHeight = 215, -- 宏正文滚动区域高度
    charLimitOffsetY = 0, -- 字数提示相对右侧面板底部的偏移
    inset = 8, -- 右侧面板背景相对内容区域的包边
  },
}

local addonFrame = CreateFrame("Frame")

local function CreatePanelBackdrop(name)
  local template = BackdropTemplateMixin and "BackdropTemplate" or nil
  local backdrop = CreateFrame("Frame", ADDON_NAME .. name, MacroFrame, template)
  backdrop:SetFrameStrata(MacroFrame:GetFrameStrata())
  backdrop:SetFrameLevel(MacroFrame:GetFrameLevel() - 1)

  if backdrop.SetTemplate then
    backdrop:SetTemplate("Transparent")
  elseif backdrop.SetBackdrop then
    backdrop:SetBackdrop({
      bgFile = "Interface/Tooltips/UI-Tooltip-Background",
      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
      edgeSize = 12,
      insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    backdrop:SetBackdropColor(0.06, 0.06, 0.06, 0.9)
    backdrop:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
  end

  return backdrop
end

local function GetLeftPanelBackdrop()
  if not addonFrame.leftPanelBackdrop then
    addonFrame.leftPanelBackdrop = CreatePanelBackdrop("LeftPanelBackdrop")
  end

  return addonFrame.leftPanelBackdrop
end

local function GetRightPanelBackdrop()
  if not addonFrame.rightPanelBackdrop then
    addonFrame.rightPanelBackdrop = CreatePanelBackdrop("RightPanelBackdrop")
  end

  return addonFrame.rightPanelBackdrop
end

local function GetRightPanelLeft()
  return CONFIG.leftPanel.offsetX + CONFIG.leftPanel.width + CONFIG.rightPanel.gap
end

local function UpdatePanelBackdrops()
  local leftBackdrop = GetLeftPanelBackdrop()
  leftBackdrop:ClearAllPoints()
  leftBackdrop:SetPoint(
    "TOPLEFT",
    MacroFrame,
    "TOPLEFT",
    CONFIG.leftPanel.offsetX - CONFIG.leftPanel.inset,
    CONFIG.leftPanel.offsetY + CONFIG.leftPanel.inset
  )
  leftBackdrop:SetSize(
    CONFIG.leftPanel.width + CONFIG.leftPanel.inset * 2,
    CONFIG.leftPanel.height + CONFIG.leftPanel.inset * 2
  )
  leftBackdrop:Show()

  local rightBackdrop = GetRightPanelBackdrop()
  rightBackdrop:ClearAllPoints()
  rightBackdrop:SetPoint(
    "TOPLEFT",
    MacroFrameTextBackground,
    "TOPLEFT",
    -CONFIG.rightPanel.inset,
    CONFIG.rightPanel.inset
  )
  rightBackdrop:SetPoint(
    "BOTTOMRIGHT",
    MacroFrameTextBackground,
    "BOTTOMRIGHT",
    CONFIG.rightPanel.inset,
    -CONFIG.rightPanel.inset
  )
  rightBackdrop:Show()
end

local function ApplyLayout()
  if not MacroFrame or not MacroFrame.MacroSelector then
    return
  end

  local rightPanelLeft = GetRightPanelLeft()

  MacroFrame.MacroSelector.customStride = CONFIG.leftPanel.columns

  MacroFrame:SetWidth(CONFIG.frame.width)
  MacroFrame:SetHeight(CONFIG.frame.height)

  MacroFrame.MacroSelector:ClearAllPoints()
  MacroFrame.MacroSelector:SetPoint("TOPLEFT", MacroFrame, "TOPLEFT", CONFIG.leftPanel.offsetX, CONFIG.leftPanel.offsetY)
  MacroFrame.MacroSelector:SetWidth(CONFIG.leftPanel.width)
  MacroFrame.MacroSelector:SetHeight(CONFIG.leftPanel.height)

  MacroFrameSelectedMacroBackground:ClearAllPoints()
  MacroFrameSelectedMacroBackground:SetPoint(
    "TOPLEFT",
    MacroFrame,
    "TOPLEFT",
    rightPanelLeft,
    CONFIG.rightPanel.selectedOffsetY
  )

  MacroFrameTextBackground:ClearAllPoints()
  MacroFrameTextBackground:SetPoint(
    "TOPLEFT",
    MacroFrame,
    "TOPLEFT",
    rightPanelLeft,
    CONFIG.rightPanel.topOffsetY
  )
  MacroFrameTextBackground:SetWidth(CONFIG.rightPanel.width)
  MacroFrameTextBackground:SetHeight(CONFIG.rightPanel.height)

  MacroFrameScrollFrame:SetHeight(CONFIG.rightPanel.scrollFrameHeight)

  MacroFrameCharLimitText:ClearAllPoints()
  MacroFrameCharLimitText:SetPoint("TOP", MacroFrameTextBackground, "BOTTOM", 0, CONFIG.rightPanel.charLimitOffsetY)

  if MacroHorizontalBarLeft then
    MacroHorizontalBarLeft:ClearAllPoints()
    MacroHorizontalBarLeft:Hide()
  end

  UpdatePanelBackdrops()
end

local function InitializeMacroFrame()
  if addonFrame.initialized then
    ApplyLayout()
    return
  end

  addonFrame.initialized = true
  ApplyLayout()

  MacroFrame:HookScript("OnShow", ApplyLayout)
  hooksecurefunc("MacroFrame_Update", ApplyLayout)
end

local function TryInitialize()
  if C_AddOns and C_AddOns.IsAddOnLoaded then
    if C_AddOns.IsAddOnLoaded("Blizzard_MacroUI") then
      InitializeMacroFrame()
      return
    end
  elseif IsAddOnLoaded and IsAddOnLoaded("Blizzard_MacroUI") then
    InitializeMacroFrame()
    return
  end

  if UIParentLoadAddOn("Blizzard_MacroUI") then
    InitializeMacroFrame()
  end
end

addonFrame:RegisterEvent("ADDON_LOADED")
addonFrame:SetScript("OnEvent", function(_, _, addonName)
  if addonName == "Blizzard_MacroUI" then
    InitializeMacroFrame()
  end
end)

TryInitialize()

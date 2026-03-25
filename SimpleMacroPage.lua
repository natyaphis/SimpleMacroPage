local ADDON_NAME = ...

local CONFIG = {
  frame = {
    width = 650, -- 宏窗口总宽度
    height = 490, -- 宏窗口总高度
  },

  leftPanel = {
    columns = 6, -- 左侧宏图标每行数量
    width = 315, -- 左侧宏图标区域宽度
    height = 395, -- 左侧宏图标区域高度
    offsetX = 10, -- 左侧宏图标区域相对 MacroFrame 左侧的偏移
    offsetY = -62, -- 左侧宏图标区域相对 MacroFrame 顶部的偏移
    inset = 8, -- 左侧背景框相对内容区域的包边
    scrollbarGap = -15, -- 左侧最右一列图标与滚动条间距
  },

  rightPanel = {
    topControlsOffsetX = 0, -- 右侧顶部控件组整体水平偏移
    topControlsOffsetY = 0, -- 右侧顶部控件组整体垂直偏移

    textBoxWidth = 250, -- 右侧文本框宽度
    textBoxHeight = 220, -- 右侧文本框高度
    textBoxOffsetX = -15, -- 右侧文本框相对右侧面板基准点的水平偏移
    textBoxOffsetY = -140, -- 右侧文本框相对右侧面板基准点的垂直偏移

    gap = 24, -- 左右面板之间的视觉间距
    charLimitOffsetY = -3, -- 字数提示相对文本框底部固定下移 3 像素
    inset = 8, -- 右侧背景框相对内容区域的包边
    scrollbarGap = 3, -- 右侧文本编辑框与滚动条间距
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

local function GetRightTopGroup()
  if addonFrame.rightTopGroup then
    return addonFrame.rightTopGroup
  end

  addonFrame.rightTopGroup = CreateFrame("Frame", ADDON_NAME .. "RightTopGroup", MacroFrame)
  return addonFrame.rightTopGroup
end

local function GetRightPanelBaseLeft()
  return CONFIG.leftPanel.offsetX + CONFIG.leftPanel.width + CONFIG.rightPanel.gap
end

local function GetTextBoxLeft()
  return GetRightPanelBaseLeft() + CONFIG.rightPanel.textBoxOffsetX
end

local function GetTextBoxTopOffsetY()
  return CONFIG.rightPanel.textBoxOffsetY
end

local function GetSelectedPanelTopOffsetY()
  return -60 + CONFIG.rightPanel.topControlsOffsetY
end

local function GetTextScrollFrameBottomInset()
  return 12
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

local function UpdateMacroSelectorButtons()
  local selector = MacroFrame and MacroFrame.MacroSelector
  local scrollBox = selector and selector.ScrollBox
  if not selector or not scrollBox or not scrollBox.ForEachFrame then
    return
  end

  local scrollBar = selector.ScrollBar
  local scrollBarWidth = (scrollBar and scrollBar:GetWidth() or 16)
  local usableWidth = CONFIG.leftPanel.width - scrollBarWidth - CONFIG.leftPanel.scrollbarGap
  local iconSize = math.floor(usableWidth / CONFIG.leftPanel.columns)

  if iconSize < 24 then
    iconSize = 24
  end

  scrollBox:ForEachFrame(function(button)
    if button.SetSize then
      button:SetSize(iconSize, iconSize)
    end
  end)
end

local function PositionScrollBars()
  local selector = MacroFrame and MacroFrame.MacroSelector
  if selector and selector.ScrollBar then
    selector.ScrollBar:ClearAllPoints()
    selector.ScrollBar:SetPoint("TOPLEFT", selector, "TOPRIGHT", CONFIG.leftPanel.scrollbarGap, -2)
    selector.ScrollBar:SetPoint("BOTTOMLEFT", selector, "BOTTOMRIGHT", CONFIG.leftPanel.scrollbarGap, 2)
  end

  if MacroFrameScrollFrame and MacroFrameScrollFrame.ScrollBar then
    MacroFrameScrollFrame.ScrollBar:ClearAllPoints()
    MacroFrameScrollFrame.ScrollBar:SetPoint("TOPLEFT", MacroFrameTextBackground, "TOPRIGHT", CONFIG.rightPanel.scrollbarGap, 0)
    MacroFrameScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", MacroFrameTextBackground, "BOTTOMRIGHT", CONFIG.rightPanel.scrollbarGap, 0)
  end
end

local function RepositionRightPanelControls(rightPanelBaseLeft)
  local offsetX = CONFIG.rightPanel.topControlsOffsetX
  local offsetY = CONFIG.rightPanel.topControlsOffsetY
  local topGroup = GetRightTopGroup()

  topGroup:ClearAllPoints()
  topGroup:SetPoint("TOPLEFT", MacroFrame, "TOPLEFT", rightPanelBaseLeft + offsetX, -58 + offsetY)
  topGroup:SetSize(CONFIG.rightPanel.textBoxWidth + 140, 72)

  if MacroFrameSelectedMacroButton then
    MacroFrameSelectedMacroButton:ClearAllPoints()
    MacroFrameSelectedMacroButton:SetPoint("TOPLEFT", topGroup, "TOPLEFT", 0, 0)
  end

  if MacroFrameSelectedMacroName and MacroFrameSelectedMacroButton then
    MacroFrameSelectedMacroName:ClearAllPoints()
    MacroFrameSelectedMacroName:SetPoint("LEFT", MacroFrameSelectedMacroButton, "RIGHT", 12, 0)
  end

  if MacroEditButton and MacroFrameSelectedMacroButton then
    MacroEditButton:ClearAllPoints()
    MacroEditButton:SetPoint("TOPLEFT", MacroFrameSelectedMacroButton, "BOTTOMLEFT", 0, -8)
  end

  if MacroSaveButton then
    MacroSaveButton:ClearAllPoints()
    MacroSaveButton:SetPoint("TOPRIGHT", topGroup, "TOPRIGHT", 0, -4)
  end

  if MacroCancelButton and MacroSaveButton then
    MacroCancelButton:ClearAllPoints()
    MacroCancelButton:SetPoint("TOPLEFT", MacroSaveButton, "BOTTOMLEFT", 0, -8)
  end

  local commandLabel = MacroFrameText and MacroFrameText.Text or MacroFrameText
  if commandLabel then
    commandLabel:ClearAllPoints()
    commandLabel:SetPoint("TOPLEFT", topGroup, "BOTTOMLEFT", 0, -10)
  end
end

local function ApplyLayout()
  if not MacroFrame or not MacroFrame.MacroSelector then
    return
  end

  local rightPanelBaseLeft = GetRightPanelBaseLeft()
  local textBoxLeft = GetTextBoxLeft()
  local textBoxTopOffsetY = GetTextBoxTopOffsetY()
  local selectedPanelTopOffsetY = GetSelectedPanelTopOffsetY()

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
    rightPanelBaseLeft,
    selectedPanelTopOffsetY
  )

  MacroFrameTextBackground:ClearAllPoints()
  MacroFrameTextBackground:SetPoint(
    "TOPLEFT",
    MacroFrame,
    "TOPLEFT",
    textBoxLeft,
    textBoxTopOffsetY
  )
  MacroFrameTextBackground:SetWidth(CONFIG.rightPanel.textBoxWidth)
  MacroFrameTextBackground:SetHeight(CONFIG.rightPanel.textBoxHeight)

  MacroFrameScrollFrame:SetHeight(CONFIG.rightPanel.textBoxHeight - 22)
  MacroFrameScrollFrame:ClearAllPoints()
  MacroFrameScrollFrame:SetPoint("TOPLEFT", MacroFrameTextBackground, "TOPLEFT", 10, -10)
  MacroFrameScrollFrame:SetPoint("BOTTOMRIGHT", MacroFrameTextBackground, "BOTTOMRIGHT", -14, GetTextScrollFrameBottomInset())

  MacroFrameCharLimitText:ClearAllPoints()
  MacroFrameCharLimitText:SetPoint("TOP", MacroFrameTextBackground, "BOTTOM", 0, CONFIG.rightPanel.charLimitOffsetY)

  if MacroHorizontalBarLeft then
    MacroHorizontalBarLeft:ClearAllPoints()
    MacroHorizontalBarLeft:Hide()
  end

  RepositionRightPanelControls(rightPanelBaseLeft)
  PositionScrollBars()
  UpdateMacroSelectorButtons()
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

  local selector = MacroFrame and MacroFrame.MacroSelector
  local scrollBox = selector and selector.ScrollBox
  if scrollBox then
    hooksecurefunc(scrollBox, "Update", UpdateMacroSelectorButtons)
  end
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

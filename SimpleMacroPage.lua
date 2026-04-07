local pendingLayout = false

local function ApplyLayout()
  if not MacroFrame or not MacroFrame.MacroSelector then
    return
  end

  -- Reapply the expanded frame size after Blizzard and ElvUI skin code run.
  MacroFrame.MacroSelector.customStride = 6
  MacroFrame:SetWidth(650)
  MacroFrame:SetHeight(490)
  MacroFrame.MacroSelector:SetWidth(322.5)
  MacroFrame.MacroSelector:SetHeight(395)

  if MacroFrame.SetTemplate then
    MacroFrame:SetTemplate("Transparent")
  end

  -- Reposition and resize the macro text panel.
  MacroFrameTextBackground:ClearAllPoints()
  MacroFrameTextBackground:SetPoint("TOPLEFT", MacroFrame, "TOPLEFT", 330, -150)
  MacroFrameTextBackground:SetHeight(220)
  MacroFrameTextBackground:SetWidth(280)

  MacroFrameScrollFrame:ClearAllPoints()
  MacroFrameScrollFrame:SetPoint("TOPLEFT", MacroFrame, "TOPLEFT", 335, -155)
  MacroFrameScrollFrame:SetHeight(215)
  MacroFrameScrollFrame:SetWidth(280)

  -- Keep the edit box aligned with the scroll frame.
  MacroFrameText:ClearAllPoints()
  MacroFrameText:SetPoint("TOPLEFT", MacroFrame, "TOPLEFT", 337, -157)
  MacroFrameText:SetWidth(275)

  -- Place the character counter below the text panel and remove the divider bar anchor.
  MacroFrameCharLimitText:ClearAllPoints()
  MacroFrameCharLimitText:SetPoint("TOP", MacroFrameTextBackground, "BOTTOM", 0, -5)
  MacroHorizontalBarLeft:ClearAllPoints()

  -- Move the selected macro controls into the right panel.
  MacroFrameSelectedMacroButton:ClearAllPoints()
  MacroFrameSelectedMacroButton:SetPoint("TOPLEFT", MacroFrame, "TOPLEFT", 335, -80)

  MacroFrameSelectedMacroBackground:ClearAllPoints()
  MacroFrameSelectedMacroBackground:SetPoint("CENTER", MacroFrameSelectedMacroButton, "CENTER", 0, 0)

  MacroFrameSelectedMacroName:ClearAllPoints()
  MacroFrameSelectedMacroName:SetPoint("TOPLEFT", MacroFrameSelectedMacroButton, "TOPLEFT", 40, 0)

  -- Anchor the command label just above the text background.
  MacroFrameEnterMacroText:ClearAllPoints()
  MacroFrameEnterMacroText:SetPoint("TOPLEFT", MacroFrameTextBackground, "TOPLEFT", 0, 20)

  MacroEditButton:ClearAllPoints()
  MacroEditButton:SetPoint("TOPLEFT", MacroFrameSelectedMacroButton, "TOPLEFT", 40, -18)

  MacroCancelButton:ClearAllPoints()
  MacroCancelButton:SetPoint("TOPLEFT", MacroFrameSelectedMacroButton, "TOPLEFT", 220, -35)
end

local function RequestLayout()
  if InCombatLockdown() then
    pendingLayout = true
    return
  end

  pendingLayout = false
  ApplyLayout()
end

local function Initialize()
  if not UIParentLoadAddOn("Blizzard_MacroUI") then
    return
  end

  RequestLayout()

  if not MacroFrame.__simpleMacroPageHooked then
    MacroFrame.__simpleMacroPageHooked = true
    MacroFrame:HookScript("OnShow", function()
      C_Timer.After(0, RequestLayout)
    end)
  end

  if not SimpleMacroPageFrame then
    local frame = CreateFrame("Frame", "SimpleMacroPageFrame")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:SetScript("OnEvent", function(_, event)
      if event == "PLAYER_REGEN_ENABLED" and pendingLayout then
        RequestLayout()
      end
    end)
  end
end

Initialize()

if UIParentLoadAddOn("Blizzard_MacroUI") then
  -- Expand the main frame and macro selector area.
  MacroFrame.MacroSelector.customStride = 6
  MacroFrame:SetWidth(650)
  MacroFrame:SetHeight(490)
  MacroFrame.MacroSelector:SetWidth(320)
  MacroFrame.MacroSelector:SetHeight(395)

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

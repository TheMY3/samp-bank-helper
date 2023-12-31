script_name("BankHelper")
script_version_number(232)
script_version("7.2")
script_authors("TheMY3", "Andrew_Medverson")
local requests = require 'requests'
local sampev = require "lib.samp.events"
require "lib.moonloader"
local imgui = require "imgui"
local memory = require 'memory'
local encoding = require "encoding"
encoding.default = 'CP1251'
u8 = encoding.UTF8
local mw = imgui.ImBool(false)
local sw, sh = getScreenResolution()
local popolnenieDeposit = tonumber(0)

local allTaxesListItem = -1

local businessListItem = -1
local houseListItem = -1
local car = -1
local communalPaymentListItem = -1
local deposit = -1
local pokaz = false
local netnalogabiz = true
local netnalogamashini = true

local configFileName = 'auto_pd.ini'
local cmdPrefix = '[' .. thisScript().name .. ']: '
local chatPrefix = '{00FF00}[' .. thisScript().name .. ']{FFFFFF} '

local updateUrl = 'https://gist.githubusercontent.com/TheMY3/9d339515be2e266e31d838e95974d491/raw'
local discordName = 'TheMY3'
-- Cheat codes
local menuChatCommand = 'apd'
local bankCheatCode = 'oo'

local menu = 2
local global_scale = imgui.ImFloat(1.2)

local inicfg = require('inicfg')
local mainIni = inicfg.load({
    vk = {
        group_token = '',
        user_id = '',
        group_id = '',
        notf_payday = false,
        notf_popolnenie = false,
        notf_pokushal = false,
        notf_pohililsya = false,
        script_umer = false
    },
    config = {
        popolnenie = false,
        sli = 0,
        strochka = '',
        autopassw = false,
        password = '',
        depositP = tonumber(0),
        zarabotal = tonumber(0),
        schetDeposit = tonumber(0),
        isPayAllTaxes = false,
        autonalogbiznes = false,
        autonalogdoma = false,
        autonalogmashini = false,
        autonalogkomunalka = false,
        autokushat = false,
        kushatprocent = tonumber(1),
        eatmetod = 0,
        autoheal = false,
        healmtd = 0,
        healprocent = tonumber(20),
        kolvodrugs = '',
        theme = 1,
        silentMode = false
    }
}, configFileName)
local silentMode = imgui.ImBool(mainIni.config.silentMode)
--VK settings
local group_token = imgui.ImBuffer('' .. mainIni.vk.group_token, 256)
local user_id = imgui.ImBuffer('' .. mainIni.vk.user_id, 256)
local group_id = imgui.ImBuffer('' .. mainIni.vk.group_id, 256)
--VK notf
local notf_payday = imgui.ImBool(mainIni.vk.notf_payday)
local notf_popolnenie = imgui.ImBool(mainIni.vk.notf_popolnenie)
local notf_pokushal = imgui.ImBool(mainIni.vk.notf_pokushal)
local notf_pohililsya = imgui.ImBool(mainIni.vk.notf_pohililsya)
local script_umer = imgui.ImBool(mainIni.vk.script_umer)

--�������������� ��������
local isDepositRefillEnabled = imgui.ImBool(mainIni.config.popolnenie)
local depositRefillAmount = imgui.ImInt(mainIni.config.sli)

--�������� ������
local isAutoPassword = imgui.ImBool(mainIni.config.autopassw)
local bankCardPassword = imgui.ImBuffer('' .. mainIni.config.password, 256)
--����������
local isPayAllTaxes = imgui.ImBool(mainIni.config.isPayAllTaxes)
local isPayBusinessTax = imgui.ImBool(mainIni.config.autonalogbiznes)
local isPayHouseTax = imgui.ImBool(mainIni.config.autonalogdoma)
local isPayCarTax = imgui.ImBool(mainIni.config.autonalogmashini)
local isPayCommunalPayment = imgui.ImBool(mainIni.config.autonalogkomunalka)
--�������
local eatMethod = imgui.ImInt(mainIni.config.eatmetod)
local eatPercentMinLimit = imgui.ImInt(mainIni.config.kushatprocent)
local isAutoEatEnabled = imgui.ImBool(mainIni.config.autokushat)
--�������
local isAutoHealEnabled = imgui.ImBool(mainIni.config.autoheal)
local healMethod = imgui.ImInt(mainIni.config.healmtd)
local healPercentMinLimit = imgui.ImInt(mainIni.config.healprocent)
local drugsAmount = imgui.ImBuffer('' .. mainIni.config.kolvodrugs, 256)
--����
local theme = imgui.ImInt(mainIni.config.theme)
--�������
local antiAfk = imgui.ImBool(false)

local status1 = inicfg.load(mainIni, configFileName)
if not doesFileExist('moonloader/config/' .. configFileName) then
    inicfg.save(mainIni, configFileName)
end

local eatList = {
    u8 '�����',
    u8 '�������',
    u8 '����� � �����',
    u8 '��� � ����������',
    u8 '�����'
}
local themeList = {
    u8 '����� ����',
    u8 '������� ����',
    u8 '�����-��������� ����',
    u8 '����� ����',
    u8 '�����-������� ����'
}
local healList = {
    u8 '�������',
    u8 '���������',
    u8 '���������',
    u8 '����',
    u8 '��� � ����������'
}

local encodeUrl = function(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return u8:encode(str, 'CP1251')
end
local vkRequest = function(message)
    requests.get('https://api.vk.com/method/messages.send?v=5.80&message=' .. encodeUrl(message) .. '&user_id=' .. user_id.v .. '&access_token=' .. group_token.v)
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then
        return
    end
    while not isSampAvailable() do
        wait(100)
    end
    autoUpdate(thisScript().name, cmdPrefix, discordName)
    sampAddChatMessage(chatPrefix .. '��������� ���� /' .. menuChatCommand, -1)
    sampAddChatMessage(chatPrefix .. '������: ' .. thisScript().version .. '. ������: ' .. table.concat(thisScript().authors, ', '), -1)

    sampRegisterChatCommand(menuChatCommand, apd1)
    while true do
        wait(0)

        if mw.v == false then
            imgui.Process = false
        end
        if theme.v == 0 then
            blueTheme()
        elseif theme.v == 1 then
            redTheme()
        elseif theme.v == 2 then
            blackOrangeTheme()
        elseif theme.v == 3 then
            greyTheme()
        elseif theme.v == 4 then
            darkRedTheme()
        end

        if sampTextdrawIsExists(2061) then
            _, _, eat, _ = sampTextdrawGetBoxEnabledColorAndSize(2061)
            eat = (eat - imgui.ImVec2(sampTextdrawGetPos(2061)).x) * 1.83
            eat1 = eat
            if math.floor(eat) < eatPercentMinLimit.v then
                if isAutoEatEnabled.v then
                    chatMessage = '������� ���������� �� ' .. math.floor(eat1) .. ', ������� ������'
                    if silentMode.v then
                        sampfuncsLog(cmdPrefix .. chatMessage)
                    else
                        sampAddChatMessage(chatPrefix .. chatMessage, -1)
                    end
                    wait(500)
                    if eatMethod.v == 0 then
                        sampSendChat('/cheeps')
                        if notf_pokushal.v then
                            vkRequest('�� �������� �����. ���� �������: ' .. math.floor(eat1))
                        end
                    elseif eatMethod.v == 1 then
                        sampSendChat('/jmeat')
                        if notf_pokushal.v then
                            vkRequest('�� �������� �������. ���� �������: ' .. math.floor(eat1))
                        end
                    elseif eatMethod.v == 2 then
                        sampSendChat('/meatbag')
                        if notf_pokushal.v then
                            vkRequest('�� �������� ���� � �����. ���� �������: ' .. math.floor(eat1))
                        end
                    elseif eatMethod.v == 3 then
                        sampSendClickTextdraw(648)
                        if notf_pokushal.v then
                            vkRequest('�� �������� ��� � ����������. ���� �������: ' .. math.floor(eat1))
                        end
                    elseif eatMethod.v == 4 then
                        sampSendChat('/jfish')
                        if notf_pokushal.v then
                            vkRequest('�� �������� �����. ���� �������: ' .. math.floor(eat1))
                        end
                    end
                    wait(5000)
                end
            end
        end

        if testCheat(bankCheatCode) and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampAddChatMessage(chatPrefix .. '������� �������� ���������� ��������', -1)

            if isPayAllTaxes.v then
                if allTaxesListItem ~= -1 then
                    setVirtualKeyDown(VK_N, true)
                    wait(500)
                    setVirtualKeyDown(VK_N, false)
                    sampSendDialogResponse(33, 1, allTaxesListItem, false)
                    wait(1000)
                    sampSendDialogResponse(15252, 1, 0, false)
                    wait(500)
                    sampCloseCurrentDialogWithButton(0)
                    wait(500)
                    allTaxesListItem = -1
                end
            end

            if isPayBusinessTax.v then
                if businessListItem ~= -1 then
                    setVirtualKeyDown(VK_N, true)
                    wait(500)
                    setVirtualKeyDown(VK_N, false)
                    sampSendDialogResponse(33, 1, businessListItem, false)
                    wait(1000)
                    sampSendDialogResponse(9762, 1, 0, false)
                    wait(1000)
                    if netnalogabiz then
                        bizov = sampGetListboxItemsCount()
                    end
                    sampSendDialogResponse(784, 1, 0, false)
                    wait(500)
                    sampCloseCurrentDialogWithButton(0)
                    wait(500)
                    if netnalogabiz then
                        if bizov ~= 1 then
                            for i = 1, tonumber(bizov - 1) do
                                setVirtualKeyDown(VK_N, true)
                                wait(500)
                                setVirtualKeyDown(VK_N, false)
                                sampSendDialogResponse(33, 1, businessListItem, false)
                                wait(500)
                                sampSendDialogResponse(9762, 1, 0, false)
                                wait(500)
                                sampSendDialogResponse(784, 1, 0, false)
                                wait(500)
                                sampCloseCurrentDialogWithButton(0)
                                wait(500)
                            end
                        end
                    end
                    businessListItem = -1
                    bizov = -1
                end
            end
            wait(300)

            houseCount = 0
            if isPayHouseTax.v then
                if houseListItem ~= -1 then
                    setVirtualKeyDown(VK_LMENU, true)
                    wait(300)
                    setVirtualKeyDown(VK_LMENU, false)
                    wait(300)
                    sampSendDialogResponse(33, 1, houseListItem, false)
                    wait(200)
                    houseCount = sampGetListboxItemsCount()
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                    wait(200)
                    sampAddChatMessage(chatPrefix .. '������� �����: ' .. houseCount, -1)
                    if houseCount ~= 0 then
                        for d = 0, tonumber(houseCount - 1) do
                            setVirtualKeyDown(VK_LMENU, true)
                            wait(300)
                            setVirtualKeyDown(VK_LMENU, false)
                            wait(500)
                            sampSendDialogResponse(33, 1, houseListItem, false)
                            wait(300)
                            sampSendDialogResponse(7238, 1, d, false)
                            wait(300)
                            sampSendDialogResponse(783, 1, 0, false)
                            wait(300)
                            sampCloseCurrentDialogWithButton(0)
                            wait(300)
                        end
                        sampAddChatMessage(chatPrefix .. '��� ������ �� ���� ��������', -1)
                    else
                        sampAddChatMessage(chatPrefix .. '���� �� �������', -1)
                    end
                else
                    sampAddChatMessage(chatPrefix .. '����� �� ������ ������ �� ��� �� ������', -1)
                end
                wait(300)
            end

            if isPayCarTax.v then
                if car ~= -1 then
                    setVirtualKeyDown(VK_N, true)
                    wait(300)
                    setVirtualKeyDown(VK_N, false)
                    sampSendDialogResponse(33, 1, car, false)
                    wait(300)
                    sampSendDialogResponse(881, 1, 0, false)
                    wait(300)
                    if netnalogamashini then
                        mashin = sampGetListboxItemsCount()
                    end
                    sampSendDialogResponse(882, 1, 0, false)
                    wait(300)
                    sampCloseCurrentDialogWithButton(0)
                    wait(300)
                    if netnalogamashini then
                        if mashin ~= 1 then
                            for b = 0, tonumber(mashin - 1) do
                                setVirtualKeyDown(VK_N, true)
                                wait(300)
                                setVirtualKeyDown(VK_N, false)
                                sampSendDialogResponse(33, 1, car, false)
                                wait(300)
                                sampSendDialogResponse(881, 1, 0, false)
                                wait(300)
                                sampSendDialogResponse(882, 1, 0, false)
                                wait(300)
                                sampCloseCurrentDialogWithButton(0)
                                wait(300)
                            end
                        end
                    end
                end

            end

            netnalogamashini = true

            if isPayCommunalPayment.v then
                if communalPaymentListItem ~= -1 then
                    for g = 0, tonumber(houseCount - 1) do
                        setVirtualKeyDown(VK_LMENU, true)
                        wait(300)
                        setVirtualKeyDown(VK_LMENU, false)
                        wait(500)
                        sampSendDialogResponse(33, 1, communalPaymentListItem, false)
                        wait(300)
                        sampSendDialogResponse(7238, 1, g, false)
                        wait(300)
                        sampSendDialogResponse(1783, 1, 0, false)
                        wait(300)
                        sampCloseCurrentDialogWithButton(0)
                        wait(300)
                    end

                end
            end
        end

        if isAutoHealEnabled.v then
            if getCharHealth(PLAYER_PED) ~= 0 and getCharHealth(PLAYER_PED) < healPercentMinLimit.v then
                if healMethod.v == 0 then
                    sampAddChatMessage(chatPrefix .. '����� ���������', -1)
                    wait(300)
                    sampSendChat('/usemed')
                    wait(2000)
                    if notf_pohililsya.v then
                        vkRequest('�� ���������� �������� ! ���� ��: ' .. getCharHealth(PLAYER_PED))
                    end
                end
                if healMethod.v == 1 then
                    sampAddChatMessage(chatPrefix .. '����� ���������', -1)
                    wait(300)
                    sampSendChat('/usedrugs ' .. drugsAmount.v)
                    wait(2000)
                    if notf_pohililsya.v then
                        vkRequest('�� ���������� ����������� ! ���� ��: ' .. getCharHealth(PLAYER_PED))
                    end
                end
                if healMethod.v == 2 then
                    sampAddChatMessage(chatPrefix .. '����� ���������', -1)
                    wait(300)
                    sampSendChat('/adrenaline')
                    wait(2000)
                    if notf_pohililsya.v then
                        vkRequest('�� ���������� ��������� ���������� ! ���� ��: ' .. getCharHealth(PLAYER_PED))
                    end
                end
                if healMethod.v == 3 then
                    sampAddChatMessage(chatPrefix .. '����� ���������', -1)
                    wait(300)
                    sampSendChat('/beer')
                    wait(2000)
                    if notf_pohililsya.v then
                        vkRequest('�� ���������� ����� ! ���� ��: ' .. getCharHealth(PLAYER_PED))
                    end
                end
                if healMethod.v == 4 then
                    sampAddChatMessage(chatPrefix .. '����� ���������', -1)
                    wait(300)
                    sampSendClickTextdraw(645)
                    wait(2000)
                    if notf_pohililsya.v then
                        vkRequest('�� ���������� ����� � ���������� ! ���� ��: ' .. getCharHealth(PLAYER_PED))
                    end
                end
            end
        end
    end
end
function imgui.OnDrawFrame()
    imgui.ShowCursor = mw.v
    imgui.SetNextWindowSize(imgui.ImVec2(600, 400), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), (sh / 2)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5), imgui.WindowFlags.AlwaysAutoResize)
    imgui.Begin(thisScript().name .. ' V' .. thisScript().version, mw, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.MenuBar)
    imgui.BeginMenuBar()
    imgui.SetCursorPosX(40)
    if imgui.MenuItem(u8 '�������� ��� �����') then
        menu = 1
    end

    if imgui.MenuItem(u8 '��������� ��� ���������') then
        menu = 2
    end

    if imgui.MenuItem(u8 'VK �����������') then
        menu = 3
    end

    if imgui.MenuItem(u8 '� �������') then
        menu = 4
    end
    imgui.EndMenuBar()

    if menu == 1 then
        imgui.Checkbox(u8 '���� ���� ������', isAutoPassword)
        if isAutoPassword.v then
            if pokaz then
                imgui.PushItemWidth(250)
                imgui.InputText(u8 '������� ������ �� �����', bankCardPassword)
            else
                imgui.PushItemWidth(250)
                imgui.InputText(u8 '������� ������ �� �����', bankCardPassword, imgui.InputTextFlags.Password)
            end
            imgui.SameLine()
            if imgui.Button(pokaz and u8 '������ ������' or u8 '�������� ������') then
                pokaz = not pokaz
            end
        end

        imgui.Separator()
        imgui.Checkbox(u8 '���� ���������� �������� � PayDay', isDepositRefillEnabled)
        if isDepositRefillEnabled.v then
            imgui.PushItemWidth(200)
            imgui.InputInt(u8 '����� ����������', depositRefillAmount)
            if depositRefillAmount.v > 10000000 then
                depositRefillAmount.v = 10000000
            end
            imgui.PushItemWidth(120)
            imgui.Text(u8 '���������� ������ ����� � ���������� ������')
        end
        imgui.Separator()

        imgui.Text(u8 '��� ��������� ������� ' .. bankCheatCode)


        imgui.Checkbox(u8 '���������� ���� ������� - �������� ������ ������ ����� � ���������� {B83434}"������� ������"', isPayAllTaxes)
        if isPayAllTaxes.v == false then
            imgui.Checkbox(u8 '���������� �����', isPayBusinessTax)
            imgui.Checkbox(u8 '���������� �����', isPayHouseTax)
            if isPayHouseTax.v then
                imgui.Checkbox(u8 '���������� ����������', isPayCommunalPayment)
            end
            if isPayHouseTax.v == false then
                isPayCommunalPayment.v = false
            end
            imgui.Checkbox(u8 '���������� �����', isPayCarTax)
        end

        imgui.Separator()
        if imgui.Button(u8 '����� �����������: $' .. mainIni.config.depositP, imgui.ImVec2(285, 20)) then
            sampAddChatMessage('����� �����������: {B83434}$' .. mainIni.config.depositP, -1)
        end
        imgui.SameLine()
        if imgui.Button(u8 '�������� ����������', imgui.ImVec2(285, 20)) then
            mainIni.config.depositP = tonumber(0)
            inicfg.save(mainIni, configFileName)
            sampAddChatMessage('������� ������ ����� ����������', -1)
        end
        imgui.Separator()
        if imgui.Button(u8 '����� ����������: $' .. mainIni.config.zarabotal, imgui.ImVec2(285, 20)) then
            sampAddChatMessage('����� ����������: {B83434}$' .. mainIni.config.zarabotal, -1)
        end
        imgui.SameLine()
        if imgui.Button(u8 '�������� ������������', imgui.ImVec2(285, 20)) then
            mainIni.config.zarabotal = tonumber(0)
            inicfg.save(mainIni, configFileName)
            sampAddChatMessage('������� ������ ������������', -1)
        end
        --imgui.SetCursorPos(imgui.ImVec2(190,410))
        if imgui.Button(u8 '��������� ��� ���������', imgui.ImVec2(580, 30)) then
            saveConfig()
        end
    elseif menu == 2 then
        imgui.Checkbox(u8 '�� ���������� ��������� � ���', silentMode)
        imgui.Separator()
        imgui.Checkbox(u8 '������� ', isAutoEatEnabled)
        if isAutoEatEnabled.v then
            imgui.Combo(u8 '����� ������� ���', eatMethod, eatList, -1)
            imgui.Text(u8 '������� ������, ��� ������� ������:')
            imgui.SliderInt(u8 '', eatPercentMinLimit, 1, 99)
        end
        imgui.Separator()
        imgui.Checkbox(u8 '�������', isAutoHealEnabled)
        if isAutoHealEnabled.v then
            imgui.Text(u8 '������� ��������, ��� ������� ��������:')
            imgui.SliderInt(' ', healPercentMinLimit, 1, 99)
            imgui.Combo(u8 '����� ������� ����', healMethod, healList, -1)
            imgui.PushItemWidth(50)
            if healMethod.v == 1 then
                imgui.InputText(u8 '���-�� ����������', drugsAmount)
            end
        end
        imgui.Separator()

        if imgui.Checkbox(u8 '�������', antiAfk) then
            antiPause()
        end

        --imgui.SetCursorPos(imgui.ImVec2(190,400))
        if imgui.Button(u8 '��������� ��������� ��� ���������', imgui.ImVec2(580, 30)) then
            mainIni.config.autokushat = isAutoEatEnabled.v
            mainIni.config.kushatprocent = eatPercentMinLimit.v
            mainIni.config.eatmetod = eatMethod.v
            mainIni.config.autoheal = isAutoHealEnabled.v
            mainIni.config.healprocent = healPercentMinLimit.v
            mainIni.config.healmtd = healMethod.v
            mainIni.config.kolvodrugs = drugsAmount.v
            inicfg.save(mainIni, configFileName)
            sampAddChatMessage(chatPrefix .. '{FFA500}�������� ��������� �������/��������', -1)
        end
    elseif menu == 3 then
        if imgui.Button(u8 '��� ��� ��� ��������� ���� ?', imgui.ImVec2(580, 30)) then
            imgui.OpenPopup('##VK')
        end
        if imgui.BeginPopup('##VK') then
            imgui.TextWrapped(u8 '�������� ������: \n1) ������� ������ �� "������ �� ���������" � ����� ��������� \n2) ������� � "����������", ����� � ��������� � ��������� ��, �������� � ��������� ��� ����� � ��������� ����������� �����')
            imgui.TextWrapped(u8 '3) �������� ����� ������ (��������� - ������ � API - ������� ����, ����� ��� �����������)')
            imgui.Text(u8 '4)����������� ������� � ���� ������ � �������� ����� ���������!')
            if imgui.Button(u8 '�������') then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
        imgui.PushItemWidth(300)
        imgui.InputText(u8 '����� ������ (3 �����)', group_token)
        imgui.PushItemWidth(300)
        imgui.InputText(u8 '���� ������������ (����������� �����)', user_id)
        imgui.PushItemWidth(300)
        imgui.InputText(u8 '���� ������ (����������� �����)', group_id)
        imgui.Text(u8 '��������� ����������� �����: ')
        imgui.Checkbox(u8 '������ PayDay � ���������� � PayDay', notf_payday)
        imgui.Checkbox(u8 '�������� �������� �������', notf_popolnenie)
        imgui.Checkbox(u8 '�������� ������� ', notf_pokushal)
        imgui.Checkbox(u8 '�������� ���������', notf_pohililsya)
        imgui.Checkbox(u8 '������ ���� =( ', script_umer)
        if imgui.Button(u8 '��������', imgui.ImVec2(580, 30)) then
            vkRequest('��, ��� ������ ������ !')
        end
        if imgui.Button(u8 '��������� ��� ���������', imgui.ImVec2(580, 30)) then
            mainIni.vk.group_token = group_token.v
            mainIni.vk.user_id = user_id.v
            mainIni.vk.notf_payday = notf_payday.v
            mainIni.vk.notf_popolnenie = notf_popolnenie.v
            mainIni.vk.notf_pokushal = notf_pokushal.v
            mainIni.vk.notf_pohililsya = notf_pohililsya.v
            mainIni.vk.script_umer = script_umer.v
            mainIni.vk.group_id = group_id.v
            inicfg.save(mainIni, configFileName)
            sampAddChatMessage(chatPrefix .. '{FFA500}�������� ��������� ����������� ��� VK', -1)
        end
    elseif menu == 4 then
        imgui.SetCursorPosX(240)
        imgui.TextColored(imgui.ImVec4(0, 143, 0, 1), u8 'Author  -  GovnoCode.lua ')
        if imgui.Button(u8 '���� �� BlastHack', imgui.ImVec2(580, 30)) then
            os.execute('explorer https://www.blast.hk/threads/52319/')
        end
        if imgui.Button(u8 '������ VK', imgui.ImVec2(580, 30)) then
            os.execute('explorer https://vk.com/govnocode_lua')
        end
        if imgui.Button(u8 '������������ ��� ��������� � �������', imgui.ImVec2(580, 30)) then
            restoreConfig()
        end
        imgui.Text(u8 '����� ���� ����:')
        imgui.PushItemWidth(450)
        imgui.SameLine()
        if imgui.Combo(u8 '', theme, themeList, -1) then
            mainIni.config.theme = theme.v
            inicfg.save(mainIni, configFileName)
        end
        if imgui.Button(u8 '��������� ����������!', imgui.ImVec2(580, 30)) then
            autoUpdate(thisScript().name, cmdPrefix, discordName)
        end
        --imgui.BeginChild("##new", imgui.ImVec2(580, 300), true, imgui.WindowFlags.NoScrollbar)
        --imgui.Text(u8'������� ����������: ')
        if imgui.Button(u8 '������� ����������', imgui.ImVec2(580, 30)) then
            imgui.OpenPopup('##storychange')
        end
        if imgui.BeginPopupModal('##storychange', true, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize) then
            imgui.Text(new)
            local wid = imgui.GetWindowWidth()
            imgui.SetCursorPosX(wid / 2 - 50)
            if imgui.Button(u8 '�������', imgui.ImVec2(100, 30)) then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
    end
    imgui.End()
end
function apd1()
    mw.v = not mw.v
    imgui.Process = mw.v
end

function sampev.onServerMessage(color, message)
    lua_thread.create(function()
        if message:find('�� �������� �� ���� ���������� ���� %$(%d+)') then
            popolnenieDeposit = message:match('�� �������� �� ���� ���������� ���� %$(%d+)')
            depositP = tonumber(mainIni.config.depositP) + tonumber(popolnenieDeposit)
            if notf_popolnenie.v then
                vkRequest('�� �������� �� �������: ' .. popolnenieDeposit .. '$ | �� ��� ����� �������� ' .. depositP .. '$')
            end
            mainIni.config.depositP = tonumber(depositP)
            inicfg.save(mainIni, configFileName)
        end
        if message:find('������� � �����: %$(%d+)') then
            currentDepositAmount = message:match('������� � �����: %$(%d+)')
            currentDepositProfit = tonumber(mainIni.config.zarabotal) + tonumber(currentDepositAmount)
            mainIni.config.zarabotal = tonumber(currentDepositProfit)
            inicfg.save(mainIni, configFileName)
        end
        if message:find('������� ����� �� ��������: ') then
            mainIni.config.schetDeposit = message:match('������� ����� �� ��������: %$(%d+)')
            inicfg.save(mainIni, configFileName)
        end
        if message:find('������� � �����: %$(%d+)') or message:find('���������� ���') or message:find('����� � �������: ') or message:find('������� ����� � �����: ') or message:find('������� ����� �� ��������: ') or message:find('� ������ ������ � ��� ') then
            if notf_payday.v then
                vkRequest(message)
            end

        end
        if message:find('���������� ���') or message:find('������� � �����: ') then
            if isDepositRefillEnabled.v then
                setVirtualKeyDown(VK_LMENU, true)
                wait(400)
                setVirtualKeyDown(VK_LMENU, false)
                wait(500)
                sampSendDialogResponse(33, 1, deposit, false)
                wait(1500)
                sampSendDialogResponse(4498, 1, 1, depositRefillAmount.v)
                wait(500)
                sampCloseCurrentDialogWithButton(0)
            end
        end

    end)
    if message:find('�� ������ ������, ��� �� ���� ������� ����� �� ������!', -1347440641) then
        netnalogabiz = false
    end
    if message:find('� ��� ��� ������ �� ������ ���������!') then
        netnalogamashini = false
    end
    if message:find('� ��� ��� ����� � �����') or message:find('� ���� ���') and not message:find('�������') then
        isAutoEatEnabled.v = false
        if notf_pokushal.v then
            vkRequest('���� �������: ' .. eat1 .. ', �� � ��� ��� ��� =(')
        end
    end
end

function sampev.onShowDialog(dialogId, dialogStyle, dialogTitle, okButtonText, cancelButtonText, dialogText)

    if mainIni.config.autopassw then
        if dialogId == 991 then
            sampSendDialogResponse(991, 1, 0, mainIni.config.password)
        end
    end
    --������ ������� ���������� �������
    local countbiznes = 0
    local counthome = 0
    local countcar = 0
    local countkomm = 0
    --autodepos
    local countdeposit = 0
    for n in dialogText:gmatch('[^\r\n]+') do
        if n:find('�������� ����������') then
            communalPaymentListItem = countkomm
        elseif n:find('�������� ����� �� ���������') then
            car = countcar
        elseif n:find('�������� ������ �� ���') then
            houseListItem = counthome
        elseif n:find('�������� ������ �� ������') then
            businessListItem = countbiznes
        elseif n:find('������ ���� �������') then
            allTaxesListItem = countbiznes
        elseif n:find('��������� �������') then
            deposit = countdeposit
        end


        -- Change to 1 variable
        countbiznes = countbiznes + 1
        counthome = counthome + 1
        countcar = countcar + 1
        countkomm = countkomm + 1
        countdeposit = countdeposit + 1
    end
    if dialogId == 9762 then
        netnalogabiz = true
    end
    if dialogId == 881 then
        netnalogamashini = true
    end
end
function saveConfig()
    --����������
    mainIni.config.password = bankCardPassword.v
    mainIni.config.autopassw = isAutoPassword.v
    --����������
    mainIni.config.isPayAllTaxes = isPayAllTaxes.v
    if isPayAllTaxes.v then
        mainIni.config.autonalogbiznes = false
        mainIni.config.autonalogdoma = false
        mainIni.config.autonalogmashini = false
        mainIni.config.autonalogkomunalka = false
    else
        mainIni.config.autonalogbiznes = isPayBusinessTax.v
        mainIni.config.autonalogdoma = isPayHouseTax.v
        mainIni.config.autonalogmashini = isPayCarTax.v
        mainIni.config.autonalogkomunalka = isPayCommunalPayment.v
    end
    --����-�������
    mainIni.config.sli = depositRefillAmount.v
    mainIni.config.popolnenie = isDepositRefillEnabled.v
    inicfg.save(mainIni, configFileName)
    sampAddChatMessage(chatPrefix .. '{FFA500}�������� ��������� ��� �����', -1)
end
function restoreConfig()
    --�������������� ��������
    isDepositRefillEnabled = imgui.ImBool(mainIni.config.popolnenie)
    --�������� ������
    isAutoPassword = imgui.ImBool(mainIni.config.autopassw)
    bankCardPassword = imgui.ImBuffer('' .. mainIni.config.password, 256)
    --����������
    isPayAllTaxes = imgui.ImBool(mainIni.config.isPayAllTaxes)
    isPayBusinessTax = imgui.ImBool(mainIni.config.autonalogbiznes)
    isPayHouseTax = imgui.ImBool(mainIni.config.autonalogdoma)
    isPayCarTax = imgui.ImBool(mainIni.config.autonalogmashini)
    isPayCommunalPayment = imgui.ImBool(mainIni.config.autonalogkomunalka)
    kolvobisnes = imgui.ImBuffer('' .. mainIni.config.kolvobisnes, 256)
    kolvodoma = imgui.ImBuffer('' .. mainIni.config.kolvodoma, 256)
    kolvomashini = imgui.ImBuffer('' .. mainIni.config.kolvomashini, 256)
    --�������
    eatMethod = imgui.ImInt(mainIni.config.eatmetod)
    eatPercentMinLimit = imgui.ImInt(mainIni.config.kushatprocent)
    isAutoEatEnabled = imgui.ImBool(mainIni.config.autokushat)
    --�������
    isAutoHealEnabled = imgui.ImBool(mainIni.config.autoheal)
    healMethod = imgui.ImInt(mainIni.config.healmtd)
    healPercentMinLimit = imgui.ImInt(mainIni.config.healprocent)
    drugsAmount = imgui.ImInt(mainIni.config.kolvodrugs)
    --����
    theme = imgui.ImInt(mainIni.config.theme)
    sampAddChatMessage(chatPrefix .. '����������� ��� ��������� � �������!', -1)
end
--Antiafk by Ronny Evans
function antiPause()
    if antiAfk.v then
        sampAddChatMessage(chatPrefix .. 'AntiAFK �������', -1)
        memory.setuint8(7634870, 1, false)
        memory.setuint8(7635034, 1, false)
        -- memory.fill(int address,int value,uint size,[bool unprotect=false])
        memory.fill(7623723, 144, 8, false)
        memory.fill(5499528, 144, 6, false)
    else
        sampAddChatMessage(chatPrefix .. 'AntiAFK ��������', -1)
        memory.setuint8(7634870, 0, false)
        memory.setuint8(7635034, 0, false)
        memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
        memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
    end
end
function onScriptTerminate(script, quitGame)
    -- script - ��������� ������ LuaScipts. ����� ��� ���� ��������� �������� �������, �.�. ���, ������� � ��.
    -- quitGame - ���������� �������� ���������� true ���� ������ ��� �������� � ���������� ���������� ����.
    if script == thisScript() then
        -- ������� ������� ��� ������ ������� ������ ��������� �����
        if script_umer.v then
            vkRequest('������ ���� =(')
        end
        memory.setuint8(7634870, 0, false)
        memory.setuint8(7635034, 0, false)
        memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
        memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
    end
end

--����� � Aniki =)
function blueTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 4.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(8.0 * global_scale.v, 4.0 * global_scale.v)
    style.ScrollbarSize = 15.0 * global_scale.v
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0 * global_scale.v
    style.GrabRounding = 1.0
    style.WindowPadding = imgui.ImVec2(8.0 * global_scale.v, 8.0 * global_scale.v)
    style.AntiAliasedLines = true
    style.AntiAliasedShapes = true
    style.FramePadding = imgui.ImVec2(4.0 * global_scale.v, 3.0 * global_scale.v)
    style.DisplayWindowPadding = imgui.ImVec2(22.0 * global_scale.v, 22.0 * global_scale.v)
    style.DisplaySafeAreaPadding = imgui.ImVec2(4.0 * global_scale.v, 4.0 * global_scale.v)
    colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg] = ImVec4(0.00, 0.00, 0.03, 0.85)
    colors[clr.ChildWindowBg] = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg] = ImVec4(0.00, 0.00, 0.03, 0.85)
    colors[clr.ComboBg] = colors[clr.PopupBg]
    colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg] = ImVec4(0.16, 0.29, 0.48, 0.5)
    colors[clr.FrameBgHovered] = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive] = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg] = ImVec4(0.1, 0.25, 0.45, 1.00)
    colors[clr.TitleBgActive] = ImVec4(0.2, 0.5, 0.9, 1.00)
    colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.MenuBarBg] = ImVec4(0.1, 0.15, 0.3, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.06, 0.8)
    colors[clr.ScrollbarGrab] = ImVec4(0.31, 0.37, 0.51, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.47, 0.61, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.51, 0.57, 0.71, 1.00)
    colors[clr.CheckMark] = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab] = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button] = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered] = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header] = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator] = colors[clr.Border]
    colors[clr.SeparatorHovered] = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive] = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.CloseButton] = ImVec4(0.9, 0.5, 0.0, 0.8)
    colors[clr.CloseButtonHovered] = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive] = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
end

--helperLovli
function redTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 4.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(8.0 * global_scale.v, 4.0 * global_scale.v)
    style.ScrollbarSize = 15.0 * global_scale.v
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0 * global_scale.v
    style.GrabRounding = 1.0
    style.WindowPadding = imgui.ImVec2(8.0 * global_scale.v, 8.0 * global_scale.v)
    style.AntiAliasedLines = true
    style.AntiAliasedShapes = true
    style.FramePadding = imgui.ImVec2(4.0 * global_scale.v, 3.0 * global_scale.v)
    style.DisplayWindowPadding = imgui.ImVec2(22.0 * global_scale.v, 22.0 * global_scale.v)
    style.DisplaySafeAreaPadding = imgui.ImVec2(4.0 * global_scale.v, 4.0 * global_scale.v)

    colors[clr.FrameBg] = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered] = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive] = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg] = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive] = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark] = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab] = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive] = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button] = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered] = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.98, 0.06, 0.06, 1.00)
    colors[clr.Header] = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered] = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive] = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator] = colors[clr.Border]
    colors[clr.SeparatorHovered] = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive] = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered] = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive] = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg] = ImVec4(0.98, 0.26, 0.26, 0.35)
    colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg] = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg] = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg] = colors[clr.PopupBg]
    colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg] = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab] = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton] = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered] = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive] = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
end

-- https://www.blast.hk/threads/25442/post-310168
function blackOrangeTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 6.0
    style.FramePadding = ImVec2(5, 5)
    style.FrameRounding = 4.0
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 9.0
    style.GrabMinSize = 5.0
    style.GrabRounding = 3.0

    colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
    colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
    colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
    colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
    colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
    colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
    colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
    colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
    colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
    colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
    colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
    colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
    colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
    colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
    colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
    colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

-- https://www.blast.hk/threads/25442/post-473803
function greyTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowPadding = ImVec2(15, 15)
    style.WindowRounding = 15.0
    style.FramePadding = ImVec2(5, 5)
    style.ItemSpacing = ImVec2(12, 8)
    style.ItemInnerSpacing = ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 15.0
    style.GrabMinSize = 15.0
    style.GrabRounding = 7.0
    style.ChildWindowRounding = 8.0
    style.FrameRounding = 6.0

    colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
    colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
    colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
    colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
    colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
    colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
    colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
    colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
    colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
    colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
    colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
    colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
    colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
    colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
    colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
    colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
    colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
    colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

-- https://www.blast.hk/threads/25442/post-503553
function darkRedTheme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowPadding = imgui.ImVec2(8, 8)
    style.WindowRounding = 6
    style.ChildWindowRounding = 5
    style.FramePadding = imgui.ImVec2(5, 3)
    style.FrameRounding = 3.0
    style.ItemSpacing = imgui.ImVec2(5, 4)
    style.ItemInnerSpacing = imgui.ImVec2(4, 4)
    style.IndentSpacing = 21
    style.ScrollbarSize = 10.0
    style.ScrollbarRounding = 13
    style.GrabMinSize = 8
    style.GrabRounding = 1
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

    colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00);
    colors[clr.TextDisabled] = ImVec4(0.29, 0.29, 0.29, 1.00);
    colors[clr.WindowBg] = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.ChildWindowBg] = ImVec4(0.12, 0.12, 0.12, 1.00);
    colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94);
    colors[clr.Border] = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.BorderShadow] = ImVec4(1.00, 1.00, 1.00, 0.10);
    colors[clr.FrameBg] = ImVec4(0.22, 0.22, 0.22, 1.00);
    colors[clr.FrameBgHovered] = ImVec4(0.18, 0.18, 0.18, 1.00);
    colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00);
    colors[clr.TitleBg] = ImVec4(0.14, 0.14, 0.14, 0.81);
    colors[clr.TitleBgActive] = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51);
    colors[clr.MenuBarBg] = ImVec4(0.20, 0.20, 0.20, 1.00);
    colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39);
    colors[clr.ScrollbarGrab] = ImVec4(0.36, 0.36, 0.36, 1.00);
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00);
    colors[clr.ScrollbarGrabActive] = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.ComboBg] = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.CheckMark] = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrab] = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrabActive] = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.Button] = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ButtonHovered] = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ButtonActive] = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.Header] = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.HeaderHovered] = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.HeaderActive] = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.ResizeGrip] = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ResizeGripHovered] = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ResizeGripActive] = ImVec4(1.00, 0.19, 0.19, 1.00);
    colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16);
    colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39);
    colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00);
    colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[clr.PlotHistogram] = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.18, 0.18, 1.00);
    colors[clr.TextSelectedBg] = ImVec4(1.00, 0.32, 0.32, 1.00);
    colors[clr.ModalWindowDarkening] = ImVec4(0.26, 0.26, 0.26, 0.60);
end

function apply_custom_style()
    blueTheme()
end

--by QRLK
function autoUpdate(name, prefix)
    local dlStatus = require('moonloader').download_status
    local json = getWorkingDirectory() .. '\\' .. name .. '-version.json'
    if doesFileExist(json) then
        os.remove(json)
    end
    downloadUrlToFile(updateUrl, json,
            function(id, status, p1, p2)
                if status == dlStatus.STATUSEX_ENDDOWNLOAD then
                    if doesFileExist(json) then
                        local f = io.open(json, 'r')
                        if f then
                            local info = decodeJson(f:read('*a'))
                            updateLink = info.updateurl
                            updateVersion = info.latest
                            new = info.new
                            f:close()
                            os.remove(json)
                            if updateVersion ~= thisScript().version then
                                lua_thread.create(function(prefix)
                                    local dlStatus = require('moonloader').download_status
                                    sampAddChatMessage(chatPrefix .. '���������� ����������. ������� ���������� c ' .. thisScript().version .. ' �� ' .. updateVersion, -1)
                                    wait(250)
                                    downloadUrlToFile(updateLink, thisScript().path,
                                            function(id3, status1, p13, p23)
                                                if status1 == dlStatus.STATUS_DOWNLOADINGDATA then
                                                    print(string.format('��������� %d �� %d.', p13, p23))
                                                elseif status1 == dlStatus.STATUS_ENDDOWNLOADDATA then
                                                    print('�������� ���������� ���������.')
                                                    sampAddChatMessage((prefix .. '���������� ���������!'), color)
                                                    goupdatestatus = true
                                                    lua_thread.create(function()
                                                        wait(500)
                                                        thisScript():reload()
                                                    end)
                                                end
                                                if status1 == dlStatus.STATUSEX_ENDDOWNLOAD then
                                                    if goupdatestatus == nil then
                                                        sampAddChatMessage(chatPrefix .. '���������� ������ ��������. �������� ���������� ������..', -1)
                                                        update = false
                                                    end
                                                end
                                            end
                                    )
                                end, cmdPrefix
                                )
                            else
                                update = false

                                sampAddChatMessage(chatPrefix .. '���������� �� ���������.', -1)
                            end
                        end
                    else
                        print('v' .. thisScript().version .. ': �� ���� ��������� ����������. ��������� ��� �������� � Discord: ' .. discordName)
                        update = false
                    end
                end
            end
    )
    while update ~= false do
        wait(100)
    end
end

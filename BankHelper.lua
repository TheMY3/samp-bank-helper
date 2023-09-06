script_name("BankHelper")
script_version_number(229)
script_version("6")
script_authors("Andrew_Medverson")
local requests = require 'requests'
local sampev = require "lib.samp.events"
local keys = require "vkeys"
require "lib.moonloader"
local imgui = require "imgui"
local memory = require 'memory'
local encoding = require "encoding"
encoding.default = 'CP1251'
u8 = encoding.UTF8
local mw = imgui.ImBool(false)
local sw, sh = getScreenResolution()
local popolnenieDeposit = tonumber(0)
local biznes = -1
local home = -1
local car = -1
local komm = -1
local deposit = -1
local pokaz = false
local netnalogabiz = true
local netnalogamashini = true

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
}, 'auto_pd.ini')
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

--Автопополнение депозита
local popolnenie = imgui.ImBool(mainIni.config.popolnenie)
local sli = imgui.ImInt(mainIni.config.sli)

--Автоввод пароля
local autopass = imgui.ImBool(mainIni.config.autopassw)
local pass = imgui.ImBuffer('' .. mainIni.config.password, 256)
--Автоналоги
local autonalogbiznes = imgui.ImBool(mainIni.config.autonalogbiznes)
local autonalogdoma = imgui.ImBool(mainIni.config.autonalogdoma)
local autonalogmashini = imgui.ImBool(mainIni.config.autonalogmashini)
local autonalogkomunalka = imgui.ImBool(mainIni.config.autonalogkomunalka)
--Автоеда
local eatmetod = imgui.ImInt(mainIni.config.eatmetod)
local kushatprocent = imgui.ImInt(mainIni.config.kushatprocent)
local autokushat = imgui.ImBool(mainIni.config.autokushat)
--Автохил
local autoheal = imgui.ImBool(mainIni.config.autoheal)
local healmtd = imgui.ImInt(mainIni.config.healmtd)
local healprocent = imgui.ImInt(mainIni.config.healprocent)
local kolvodrugs = imgui.ImBuffer('' .. mainIni.config.kolvodrugs, 256)
--Тема
local theme = imgui.ImInt(mainIni.config.theme)
--АнтиАфк
local antiafk = imgui.ImBool(false)

local status1 = inicfg.load(mainIni, 'auto_pd.ini')
if not doesFileExist('moonloader/config/auto_pd.ini') then
    inicfg.save(mainIni, 'auto_pd.ini')
end

local metod = {
    u8 'Чипсы',
    u8 'Оленина',
    u8 'Мешок с мясом',
    u8 'Еда дома',
    u8 'Еда с расстояния',
    u8 'Рыбка'
}
local thememetod = {
    u8 'Синяя тема',
    u8 'Красная тема',
    u8 'Черно-оранжевая тема'
}
local healmetod = {
    u8 'Аптечка',
    u8 'Наркотики',
    u8 'Адреналин',
    u8 'Пиво',
    u8 'Хил с расстояния'
}

local encodeUrl = function(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return u8:encode(str, 'CP1251')
end
local vkrequest = function(message)
    requests.get('https://api.vk.com/method/messages.send?v=5.80&message=' .. encodeUrl(message) .. '&user_id=' .. user_id.v .. '&access_token=' .. group_token.v)
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then
        return
    end
    while not isSampAvailable() do
        wait(100)
    end
    autoupdate("https://gist.githubusercontent.com/Andrey281/0b7e3f7707b2479db3f920d382a0385a/raw/", '[' .. string.upper(thisScript().name) .. ']: ', "http://vk.com/andreyneya")
    sampAddChatMessage('{00FF00}[BankHelper v' .. thisScript().version .. ']: {FFFFFF}Активация меню /apd или чит-код pd', -1)
    sampAddChatMessage('{00FF00}[BankHelper v' .. thisScript().version .. ']: {FFFFFF}Author - {FF0000}Andrew_Medverson', -1)
    sampRegisterChatCommand('apd', apd1)
    while true do
        wait(0)

        if mw.v == false then
            imgui.Process = false
        end
        if testCheat('pd') then
            apd1()
        end
        if theme.v == 0 then
            apply_custom_style()
        elseif theme.v == 1 then
            redTheme()
        elseif theme.v == 2 then
            blackOrangeTheme()
        elseif theme.v == 3 then
            greyTheme()
        end
        if sampTextdrawIsExists(2061) then
            _, _, eat, _ = sampTextdrawGetBoxEnabledColorAndSize(2061)
            eat = (eat - imgui.ImVec2(sampTextdrawGetPos(2061)).x) * 1.83
            eat1 = eat
            if math.floor(eat) < kushatprocent.v then
                if autokushat.v then
                    if silentMode.v then
                        sampfuncsLog('[BankHelper] чичас поем')
                    else
                        sampAddChatMessage('{00FF00}[BankHelper]{FFFFFF} чичас поем ', -1)
                    end
                    wait(500)
                    if eatmetod.v == 0 then
                        sampSendChat('/cheeps')
                        wait(4000)
                        if notf_pokushal.v then
                            vkrequest('Вы покушали чипсы. Ваша сытость: ' .. math.floor(eat1))
                        end
                    elseif eatmetod.v == 1 then
                        sampSendChat('/jmeat')
                        wait(4000)
                        if notf_pokushal.v then
                            vkrequest('Вы покушали оленину. Ваша сытость: ' .. math.floor(eat1))
                        end
                    elseif eatmetod.v == 2 then
                        sampSendChat('/meatbag')
                        wait(4000)
                        if notf_pokushal.v then
                            vkrequest('Вы покушали мясо с мешка. Ваша сытость: ' .. math.floor(eat1))
                        end
                    elseif eatmetod.v == 3 then
                        sampSendChat('/home')
                        wait(900)
                        sampSendDialogResponse(174, 1, 1, false)
                        wait(900)
                        sampSendDialogResponse(2431, 1, 1, false)
                        wait(900)
                        sampSendDialogResponse(185, 1, 6, false)
                        wait(4000)
                        if notf_pokushal.v then
                            vkrequest('Вы покушали с дома. Ваша сытость: ' .. math.floor(eat1))
                        end
                    elseif eatmetod.v == 4 then
                        sampSendClickTextdraw(648)
                        wait(4000)
                        if notf_pokushal.v then
                            vkrequest('Вы покушали еду с расстояния. Ваша сытость: ' .. math.floor(eat1))
                        end
                    elseif eatmetod.v == 5 then
                        sampSendChat('/jfish')
                        wait(4000)
                        if notf_pokushal.v then
                            vkrequest('Вы покушали Рыбку. Ваша сытость: ' .. math.floor(eat1))
                        end
                    end
                end
            end
        end

        if testCheat('uu') and not sampIsChatInputActive() and not sampIsDialogActive() then
            setVirtualKeyDown(VK_N, false)
            wait(500)
            setVirtualKeyDown(VK_N, true)
            wait(1000)
            sampCloseCurrentDialogWithButton(0)
            wait(1000)
            if autonalogbiznes.v then
                if biznes ~= -1 then
                    setVirtualKeyDown(VK_N, true)
                    wait(500)
                    setVirtualKeyDown(VK_N, false)
                    sampSendDialogResponse(33, 1, biznes, false)
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
                                sampSendDialogResponse(33, 1, biznes, false)
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
                    biznes = -1
                    bizov = -1
                end

            end
            wait(300)
            if autonalogdoma.v then
                if home ~= -1 then
                    setVirtualKeyDown(VK_N, true)
                    wait(300)
                    setVirtualKeyDown(VK_N, false)
                    sampSendDialogResponse(33, 1, home, false)
                    wait(1000)
                    domov = sampGetListboxItemsCount()
                    wait(300)
                    sampSendDialogResponse(7238, 1, d, false)
                    wait(300)
                    sampSendDialogResponse(783, 1, 0, false)
                    wait(300)
                    sampCloseCurrentDialogWithButton(0)
                    wait(300)
                    if domov ~= 1 then
                        for d = 0, tonumber(domov - 2) do
                            setVirtualKeyDown(VK_N, true)
                            wait(300)
                            setVirtualKeyDown(VK_N, false)
                            sampSendDialogResponse(33, 1, home, false)
                            wait(300)
                            sampSendDialogResponse(7238, 1, tonumber(d + 1), false)
                            wait(300)
                            sampSendDialogResponse(783, 1, 0, false)
                            wait(300)
                            sampCloseCurrentDialogWithButton(0)
                            wait(300)
                        end
                    end
                end
                wait(300)
            end
            if autonalogmashini.v then
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
            if autonalogkomunalka.v then
                if komm ~= -1 then
                    for g = 0, tonumber(domov - 1) do
                        setVirtualKeyDown(VK_N, true)
                        wait(300)
                        setVirtualKeyDown(VK_N, false)
                        sampSendDialogResponse(33, 1, komm, false)
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

        if autoheal.v then
            if getCharHealth(PLAYER_PED) ~= 0 and getCharHealth(PLAYER_PED) < healprocent.v then
                if healmtd.v == 0 then
                    sampAddChatMessage('{00FF00}[BankHelper]{FFFFFF}чичас отхиляюсь', -1)
                    wait(300)
                    sampSendChat('/usemed')
                    wait(2000)
                    if notf_pohililsya.v then
                        vkrequest('Вы похилились аптечкой ! Ваше хп: ' .. getCharHealth(PLAYER_PED))
                    end
                end
                if healmtd.v == 1 then
                    sampAddChatMessage('{00FF00}[BankHelper]{FFFFFF}чичас отхиляюсь', -1)
                    wait(300)
                    sampSendChat('/usedrugs ' .. kolvodrugs.v)
                    wait(2000)
                    if notf_pohililsya.v then
                        vkrequest('Вы похилились наркотиками ! Ваше хп: ' .. getCharHealth(PLAYER_PED))
                    end
                end
                if healmtd.v == 2 then
                    sampAddChatMessage('{00FF00}[BankHelper]{FFFFFF}чичас отхиляюсь', -1)
                    wait(300)
                    sampSendChat('/adrenaline')
                    wait(2000)
                    if notf_pohililsya.v then
                        vkrequest('Вы похилились таблеткой адреналина ! Ваше хп: ' .. getCharHealth(PLAYER_PED))
                    end
                end
                if healmtd.v == 3 then
                    sampAddChatMessage('{00FF00}[BankHelper]{FFFFFF}чичас отхиляюсь', -1)
                    wait(300)
                    sampSendChat('/beer')
                    wait(2000)
                    if notf_pohililsya.v then
                        vkrequest('Вы похилились пивом ! Ваше хп: ' .. getCharHealth(PLAYER_PED))
                    end
                end
                if healmtd.v == 4 then
                    sampAddChatMessage('{00FF00}[BankHelper]{FFFFFF}чичас отхиляюсь', -1)
                    wait(300)
                    sampSendClickTextdraw(645)
                    wait(2000)
                    if notf_pohililsya.v then
                        vkrequest('Вы похилились хилом с расстояния ! Ваше хп: ' .. getCharHealth(PLAYER_PED))
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
    imgui.Begin('BankHelper V' .. thisScript().version, mw, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.MenuBar)
    imgui.BeginMenuBar()
    imgui.SetCursorPosX(40)
    if imgui.MenuItem(u8 'Помощник для банка') then
        menu = 1
    end

    if imgui.MenuItem(u8 'Настройки для персонажа') then
        menu = 2
    end

    if imgui.MenuItem(u8 'VK уведомления') then
        menu = 3
    end

    if imgui.MenuItem(u8 'О скрипте/Обновления') then
        menu = 4
    end
    imgui.EndMenuBar()

    if menu == 1 then
        imgui.Checkbox(u8 'Автоввод пароля', autopass)
        if autopass.v then
            if pokaz then
                imgui.PushItemWidth(250)
                imgui.InputText(u8 'Введите пароль от карты', pass)
            else
                imgui.PushItemWidth(250)
                imgui.InputText(u8 'Введите пароль от карты', pass, imgui.InputTextFlags.Password)
            end
            imgui.SameLine()
            if imgui.Button(pokaz and u8 'Скрыть пароль' or u8 'Показать пароль') then
                pokaz = not pokaz
            end
        end

        imgui.Separator()
        imgui.Checkbox(u8 'Автопополнение депозита в пейдей', popolnenie)
        if popolnenie.v then
            imgui.PushItemWidth(200)
            imgui.InputInt(u8 'Сумма пополнения', sli)
            if sli.v > 10000000 then
                sli.v = 10000000
            end
            imgui.PushItemWidth(120)
            imgui.Text(u8 'Необходимо стоять рядом с банковской кассой')
        end
        imgui.Separator()

        imgui.Text(u8 'Для активации нажмите uu')
        --sampAddChatMessage('u',-1)

        imgui.Checkbox(u8 'АвтоОплата Бизов', autonalogbiznes)
        imgui.Checkbox(u8 'АвтоОплата Домов', autonalogdoma)
        if autonalogdoma.v then
            imgui.Checkbox(u8 'АвтоОплата Комуналки', autonalogkomunalka)
        end
        if autonalogdoma.v == false then
            autonalogkomunalka.v = false
        end
        imgui.Checkbox(u8 'АвтоОплата Машин', autonalogmashini)
        imgui.Separator()
        if imgui.Button(u8 'Всего пополнилось: $' .. mainIni.config.depositP, imgui.ImVec2(285, 20)) then
            sampAddChatMessage('Всего пополнилось: {B83434}$' .. mainIni.config.depositP, -1)
        end
        imgui.SameLine()
        if imgui.Button(u8 'Очистить пополнение', imgui.ImVec2(285, 20)) then
            mainIni.config.depositP = tonumber(0)
            inicfg.save(mainIni, 'auto_pd.ini')
            sampAddChatMessage('Успешно удалил сумму пополнений', -1)
        end
        imgui.Separator()
        if imgui.Button(u8 'Всего заработано: $' .. mainIni.config.zarabotal, imgui.ImVec2(285, 20)) then
            sampAddChatMessage('Всего заработано: {B83434}$' .. mainIni.config.zarabotal, -1)
        end
        imgui.SameLine()
        if imgui.Button(u8 'Очистить заработанное', imgui.ImVec2(285, 20)) then
            mainIni.config.zarabotal = tonumber(0)
            inicfg.save(mainIni, 'auto_pd.ini')
            sampAddChatMessage('Успешно удалил заработанное', -1)
        end
        --imgui.SetCursorPos(imgui.ImVec2(190,410))
        if imgui.Button(u8 'Сохранить все настройки', imgui.ImVec2(580, 30)) then
            saveCFG()
        end
    elseif menu == 2 then
        imgui.Checkbox(u8 'Не отправлять сообщения в чат', silentMode)
        imgui.Separator()
        imgui.Checkbox(u8 'Автоеда ', autokushat)
        if autokushat.v then
            imgui.Combo(u8 'Выбор способа еды', eatmetod, metod, -1)
            imgui.Text(u8 'Процент голода, при котором кушать:')
            imgui.SliderInt(u8 '', kushatprocent, 1, 99)
        end
        imgui.Separator()
        imgui.Checkbox(u8 'Автохил', autoheal)
        if autoheal.v then
            imgui.Text(u8 'Процент здоровья, при котором хиляться:')
            imgui.SliderInt(' ', healprocent, 1, 99)
            imgui.Combo(u8 'Выбор способа хила', healmtd, healmetod, -1)
            imgui.PushItemWidth(50)
            if healmtd.v == 1 then
                imgui.InputText(u8 'Кол-во наркотиков', kolvodrugs)
            end
        end
        imgui.Separator()

        if imgui.Checkbox(u8 'АнтиАфк', antiafk) then
            antipause()
        end

        --imgui.SetCursorPos(imgui.ImVec2(190,400))
        if imgui.Button(u8 'Сохранить настройки для персонажа', imgui.ImVec2(580, 30)) then
            mainIni.config.autokushat = autokushat.v
            mainIni.config.kushatprocent = kushatprocent.v
            mainIni.config.eatmetod = eatmetod.v
            mainIni.config.autoheal = autoheal.v
            mainIni.config.healprocent = healprocent.v
            mainIni.config.healmtd = healmtd.v
            mainIni.config.kolvodrugs = kolvodrugs.v
            inicfg.save(mainIni, 'auto_pd.ini')
            sampAddChatMessage('{00FF00}[BankHelper]{FFA500}Сохранил настройки автоеды/автохила', -1)
        end
    elseif menu == 3 then
        if imgui.Button(u8 'Как это все настроить блин ?', imgui.ImVec2(580, 30)) then
            imgui.OpenPopup('##VK')
        end
        if imgui.BeginPopup('##VK') then
            imgui.TextWrapped(u8 'Создание группы: \n1) Создаем группу ВК "Группа по интересам" с любым названием \n2) Заходим в "управление", затем в сообщения и включаете их, заходите в настройки для ботов и включаете возможности ботов')
            imgui.TextWrapped(u8 '3) Создаете токен группы (Настройки - работа с API - создать ключ, даете все возможности)')
            imgui.Text(u8 '4)ОБЯЗАТЕЛЬНО зайдите в свою группу и напишите любое сообщение!')
            if imgui.Button(u8 'Закрыть') then
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
        imgui.PushItemWidth(300)
        imgui.InputText(u8 'Токен группы (3 пункт)', group_token)
        imgui.PushItemWidth(300)
        imgui.InputText(u8 'Айди пользователя (Обязательно цифры)', user_id)
        imgui.PushItemWidth(300)
        imgui.InputText(u8 'Айди группы (Обязательно цифры)', group_id)
        imgui.Text(u8 'Присылать уведомления когда: ')
        imgui.Checkbox(u8 'Пришел PayDay и информацию с PayDay', notf_payday)
        imgui.Checkbox(u8 'Персонаж пополнил депозит', notf_popolnenie)
        imgui.Checkbox(u8 'Персонаж покушал ', notf_pokushal)
        imgui.Checkbox(u8 'Персонаж похилился', notf_pohililsya)
        imgui.Checkbox(u8 'Скрипт умер =( ', script_umer)
        if imgui.Button(u8 'Проверка', imgui.ImVec2(580, 30)) then
            vkrequest('ку, все прошло удачно !')
        end
        if imgui.Button(u8 'Сохранить все настройки', imgui.ImVec2(580, 30)) then
            mainIni.vk.group_token = group_token.v
            mainIni.vk.user_id = user_id.v
            mainIni.vk.notf_payday = notf_payday.v
            mainIni.vk.notf_popolnenie = notf_popolnenie.v
            mainIni.vk.notf_pokushal = notf_pokushal.v
            mainIni.vk.notf_pohililsya = notf_pohililsya.v
            mainIni.vk.script_umer = script_umer.v
            mainIni.vk.group_id = group_id.v
            inicfg.save(mainIni, 'auto_pd.ini')
            sampAddChatMessage('{00FF00}[BankHelper]{FFA500}Сохранил настройки уведомлений для VK', -1)
        end
    elseif menu == 4 then
        imgui.SetCursorPosX(240)
        imgui.TextColored(imgui.ImVec4(0, 143, 0, 1), u8 'Author  -  GovnoCode.lua ')
        if imgui.Button(u8 'Тема на BlastHack', imgui.ImVec2(580, 30)) then
            os.execute('explorer https://www.blast.hk/threads/52319/')
        end
        if imgui.Button(u8 'Группа VK', imgui.ImVec2(580, 30)) then
            os.execute('explorer https://vk.com/govnocode_lua')
        end
        if imgui.Button(u8 'Восстановить все настройки с конфига', imgui.ImVec2(580, 30)) then
            vosstanovleniecfg()
        end
        imgui.Text(u8 'Выбор темы меню: ')
        imgui.PushItemWidth(450)
        imgui.SameLine()
        if imgui.Combo(u8 '', theme, thememetod, -1) then
            mainIni.config.theme = theme.v
            inicfg.save(mainIni, 'auto_pd.ini')
        end
        if imgui.Button(u8 'Проверить обновление !', imgui.ImVec2(580, 30)) then
            autoupdate("https://gist.githubusercontent.com/Andrey281/0b7e3f7707b2479db3f920d382a0385a/raw/", '[' .. string.upper(thisScript().name) .. ']: ', "http://vk.com/andreyneya")
        end
        --imgui.BeginChild("##new", imgui.ImVec2(580, 300), true, imgui.WindowFlags.NoScrollbar)
        --imgui.Text(u8'История обновлений: ')
        if imgui.Button(u8 'История обновлений', imgui.ImVec2(580, 30)) then
            imgui.OpenPopup('##storychange')
        end
        if imgui.BeginPopupModal('##storychange', true, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize) then
            imgui.Text(new)
            local wid = imgui.GetWindowWidth()
            imgui.SetCursorPosX(wid / 2 - 50)
            if imgui.Button(u8 'Закрыть', imgui.ImVec2(100, 30)) then
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
        if message:find('Вы положили на свой депозитный счет %$(%d+)') then
            popolnenieDeposit = message:match('Вы положили на свой депозитный счет %$(%d+)')
            depositP = tonumber(mainIni.config.depositP) + tonumber(popolnenieDeposit)
            if notf_popolnenie.v then
                vkrequest('Вы положили на депозит: ' .. popolnenieDeposit .. '$ | За все время положили ' .. depositP .. '$')
            end
            mainIni.config.depositP = tonumber(depositP)
            inicfg.save(mainIni, 'auto_pd.ini')
        end
        if message:find('Депозит в банке: %$(%d+)') then
            depos123 = message:match('Депозит в банке: %$(%d+)')
            zarabotal = tonumber(mainIni.config.zarabotal) + tonumber(depos123)
            mainIni.config.zarabotal = tonumber(zarabotal)
            inicfg.save(mainIni, 'auto_pd.ini')
        end
        if message:find('Текущая сумма на депозите: ') then
            mainIni.config.schetDeposit = message:match('Текущая сумма на депозите: %$(%d+)')
            inicfg.save(mainIni, 'auto_pd.ini')
        end
        if message:find('Депозит в банке: %$(%d+)') or message:find('Банковский чек') or message:find('Сумма к выплате: ') or message:find('Текущая сумма в банке: ') or message:find('Текущая сумма на депозите: ') or message:find('В данный момент у вас ') then
            if notf_payday.v then
                vkrequest(message)
            end

        end
        if message:find('Банковский чек') or message:find('Депозит в банке: ') then
            if popolnenie.v then
                setVirtualKeyDown(VK_N, true)
                wait(400)
                setVirtualKeyDown(VK_N, false)
                wait(500)
                sampSendDialogResponse(33, 1, deposit, false)
                wait(1500)
                sampSendDialogResponse(4498, 1, 1, sli.v)
                wait(500)
                sampCloseCurrentDialogWithButton(0)
            end
        end

    end)
    if message:find('На данный момент, вам не надо платить налог за бизнес!', -1347440641) then
        netnalogabiz = false
    end
    if message:find('У вас нет налога на личный транспорт!') then
        netnalogamashini = false
    end
    if message:find('У вас нет мешка с мясом') or message:find('У тебя нет') and not message:find('говорит') then
        autokushat.v = false
        if notf_pokushal.v then
            vkrequest('Ваша сытость: ' .. eat1 .. ', но у вас нет еды =(')
        end
    end
end

function sampev.onShowDialog(dialogId, dialogStyle, dialogTitle, okButtonText, cancelButtonText, dialogText)

    if mainIni.config.autopassw then
        if dialogId == 991 then
            sampSendDialogResponse(991, 1, 0, mainIni.config.password)
        end
    end
    --номера строчек автооплата налогов
    local countbiznes = 0
    local counthome = 0
    local countcar = 0
    local countkomm = 0
    --autodepos
    local countdeposit = 0
    for n in dialogText:gmatch('[^\r\n]+') do
        if n:find('Оплатить коммуналку') then
            komm = countkomm
        end
        if n:find('Оплатить налог на транспорт') then

            car = countcar
        end
        if n:find('Оплатить налоги на дом') then

            home = counthome
        end
        if n:find('Оплатить налоги на бизнес') then

            biznes = countbiznes
        end
        if n:find('Пополнить депозит') then

            deposit = countdeposit
        end
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
function saveCFG()
    --АвтоПароль
    mainIni.config.password = pass.v
    mainIni.config.autopassw = autopass.v
    --АвтоНалоги
    mainIni.config.autonalogbiznes = autonalogbiznes.v
    mainIni.config.autonalogdoma = autonalogdoma.v
    mainIni.config.autonalogmashini = autonalogmashini.v
    mainIni.config.autonalogkomunalka = autonalogkomunalka.v
    --Авто-Депозит
    mainIni.config.sli = sli.v
    mainIni.config.popolnenie = popolnenie.v
    inicfg.save(mainIni, 'auto_pd.ini')
    sampAddChatMessage('{00FF00}[BankHelper]{FFA500}Сохранил настройки для банка', -1)
end
function vosstanovleniecfg()
    --Автопополнение депозита
    popolnenie = imgui.ImBool(mainIni.config.popolnenie)
    --Автоввод пароля
    autopass = imgui.ImBool(mainIni.config.autopassw)
    pass = imgui.ImBuffer('' .. mainIni.config.password, 256)
    --Автоналоги
    autonalogbiznes = imgui.ImBool(mainIni.config.autonalogbiznes)
    autonalogdoma = imgui.ImBool(mainIni.config.autonalogdoma)
    autonalogmashini = imgui.ImBool(mainIni.config.autonalogmashini)
    autonalogkomunalka = imgui.ImBool(mainIni.config.autonalogkomunalka)
    kolvobisnes = imgui.ImBuffer('' .. mainIni.config.kolvobisnes, 256)
    kolvodoma = imgui.ImBuffer('' .. mainIni.config.kolvodoma, 256)
    kolvomashini = imgui.ImBuffer('' .. mainIni.config.kolvomashini, 256)
    --Автоеда
    eatmetod = imgui.ImInt(mainIni.config.eatmetod)
    kushatprocent = imgui.ImInt(mainIni.config.kushatprocent)
    autokushat = imgui.ImBool(mainIni.config.autokushat)
    --Автохил
    autoheal = imgui.ImBool(mainIni.config.autoheal)
    healmtd = imgui.ImInt(mainIni.config.healmtd)
    healprocent = imgui.ImInt(mainIni.config.healprocent)
    kolvodrugs = imgui.ImInt(mainIni.config.kolvodrugs)
    --Тема
    theme = imgui.ImInt(mainIni.config.theme)
    sampAddChatMessage('{00FF00}[BankHelper]{FFFFFF}Восстановил все настройки с конфига!', -1)
end
--Antiafk by Ronny Evans
function antipause()
    if antiafk.v then
        sampAddChatMessage('{00FF00}[BankHelper]{FFFFFF}AntiAFK включён', -1)
        memory.setuint8(7634870, 1, false)
        memory.setuint8(7635034, 1, false)
        -- memory.fill(int address,int value,uint size,[bool unprotect=false])
        memory.fill(7623723, 144, 8, false)
        memory.fill(5499528, 144, 6, false)
    else
        sampAddChatMessage('{00FF00}[BankHelper]{FFFFFF}AntiAFK выключен', -1)
        memory.setuint8(7634870, 0, false)
        memory.setuint8(7635034, 0, false)
        memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
        memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
    end
end
function onScriptTerminate(script, quitGame)
    -- script - указатель класса LuaScipts. Имеет все выше описанные свойства скрипта, т.е. имя, авторов и тп.
    -- quitGame - логическое значение возвращает true если скрипт был завершен в результате завершения игры.
    if script == thisScript() then
        -- зададим условие что именно текущий скрипт завершает работ
        if script_umer.v then
            vkrequest('скрипт умер =(')
        end
        memory.setuint8(7634870, 0, false)
        memory.setuint8(7635034, 0, false)
        memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
        memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
    end
end

--украл у Aniki =)
function apply_custom_style()
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

--by QRLK
function autoupdate(json_url, prefix, url)
    local dlstatus = require('moonloader').download_status
    local json = getWorkingDirectory() .. '\\' .. thisScript().name .. '-version.json'
    if doesFileExist(json) then
        os.remove(json)
    end
    downloadUrlToFile(json_url, json,
            function(id, status, p1, p2)
                if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                    if doesFileExist(json) then
                        local f = io.open(json, 'r')
                        if f then
                            local info = decodeJson(f:read('*a'))
                            updatelink = info.updateurl
                            updateversion = info.latest
                            new = info.new
                            f:close()
                            os.remove(json)
                            if updateversion ~= thisScript().version then
                                lua_thread.create(function(prefix)
                                    local dlstatus = require('moonloader').download_status
                                    local color = -1
                                    sampAddChatMessage(('{00FF00}[BankHelper]: {FFFFFF}Обнаружено обновление. Пытаюсь обновиться c ' .. thisScript().version .. ' на ' .. updateversion), color)
                                    wait(250)
                                    downloadUrlToFile(updatelink, thisScript().path,
                                            function(id3, status1, p13, p23)
                                                if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                                                    print(string.format('Загружено %d из %d.', p13, p23))
                                                elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                                                    print('Загрузка обновления завершена.')
                                                    sampAddChatMessage((prefix .. 'Обновление завершено!'), color)
                                                    goupdatestatus = true
                                                    lua_thread.create(function()
                                                        wait(500)
                                                        thisScript():reload()
                                                    end)
                                                end
                                                if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                                                    if goupdatestatus == nil then
                                                        sampAddChatMessage((prefix .. 'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
                                                        update = false
                                                    end
                                                end
                                            end
                                    )
                                end, prefix
                                )
                            else
                                update = false
                                sampAddChatMessage('{00FF00}[BankHelper v' .. thisScript().version .. ']: {FFFFFF}Обновление не требуется.', -1)
                            end
                        end
                    else
                        print('v' .. thisScript().version .. ': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на ' .. url)
                        update = false
                    end
                end
            end
    )
    while update ~= false do
        wait(100)
    end
end

AgentView = AgentView or BaseClass(BaseView)

function AgentView:__init()
    self.ui_config = {{"uis/views/agents/dev_prefab", "AgentView"}}
    self.active_close = false
    self.click_login_callback = nil
end

function AgentView:LoadCallBack()
    self.node_list["BtnLogin"].button:AddClickListener(BindTool.Bind(self.OnLoginClick, self))
    self.node_list["AccountName"].input_field.text = PlayerPrefsUtil.GetString("account_name")
    self.node_list["AccountPwd"].input_field.text = PlayerPrefsUtil.GetString("account_pwd")

    self.node_list["BtnLogin"].event_trigger_listener:AddPointerDownListener(BindTool.Bind(self.OnClickLoginDown, self))
    self.node_list["BtnLogin"].event_trigger_listener:AddPointerUpListener(BindTool.Bind(self.OnClickLoginUp, self))
end

function AgentView:SetClickLoginCallback(callback)
    self.click_login_callback = callback
end

function AgentView:OnLoginClick()
    local account_name = self.node_list["AccountName"].input_field.text
    local account_pwd = self.node_list["AccountPwd"].input_field.text

    if account_name == "" then
        TipsCtrl.Instance:ShowSystemMsg("Account cannot be empty.") --ylsp
        return
    end

    if account_pwd == "" then
        TipsCtrl.Instance:ShowSystemMsg("Password cannot be empty.") --ylsp
        return
    end

    local accountlen = string.len(account_name)
    if accountlen < 4 or accountlen > 14 then
        TipsCtrl.Instance:ShowSystemMsg("Account length must be greater than 5 digits and less than 15 digits.") --ylsp
        return
    end

    local pwdlen = string.len(account_pwd)
    if pwdlen < 6 or pwdlen > 20 then
        TipsCtrl.Instance:ShowSystemMsg("Password length must be greater than 6 characters and less than 20 characters.") --ylsp
        return
    end
	--密码验证开始 ylsp
	if nil ~= account_pwd and "" ~= account_pwd and string.len(account_name) > 4 then
	local useraccount = 'dev_'.. account_name
	local gameid = "game3d003"
	local regkey = '!!##123'
	local check_now_server_time = os.time()
	local verify_pwdchecke_url = "http://144.217.71.174:9981/api/verify.php"
	local signData = useraccount .. check_now_server_time .. regkey --签名

	local Sign
	if MD52 ~= nil then
		Sign = string.upper(MD52.GetMD5(signData))
	else
		Sign = string.upper(MD5.GetMD5FromString(signData)) 
	end

	local req_fmt = "%s?account=%s&pwd=%s&time=%s&gameid=%s&sgin=%s"
	local req_str = string.format(req_fmt, verify_pwdchecke_url, account_name, account_pwd, check_now_server_time, gameid, Sign)
	
		print("[FetchGift] request fetch", req_str)	 
		
		HttpClient:Request(req_str, function(url, arg, data, size)
    --Log("pwd, callback", url, size, "data:", data)
    --print_log("pwd, callback", url, size, "data:", data)
    if nil ~= data and "OK" == data then
        TipsCtrl.Instance:ShowSystemMsg("Landed successfully....") --ylsp
        PlayerPrefsUtil.SetString("account_name", account_name)
        PlayerPrefsUtil.SetString("account_pwd", account_pwd)
        -- PlayerPrefsUtil.SetString("account_daili", account_daili) -- Eliminado
        local newaccount_name = account_name
        self.click_login_callback(newaccount_name)
        self:Close()
    elseif nil ~= data and "1" == data then
        TipsCtrl.Instance:ShowSystemMsg("Incorrect username or password.") --ylsp
        return
    elseif nil ~= data and "2" == data then
        TipsCtrl.Instance:ShowSystemMsg("Referrer ID error, contact customer service to obtain") --ylsp
        return
    elseif nil ~= data and "3" == data then
        TipsCtrl.Instance:ShowSystemMsg("The account number can only use numbers and lowercase letters!") --ylsp
        return
    elseif nil ~= data and "4" == data then
        TipsCtrl.Instance:ShowSystemMsg("Password can only use numbers and lowercase letters!") --ylsp
        return
    elseif nil ~= data and "5" == data then
        TipsCtrl.Instance:ShowSystemMsg("Referrer ID can only use numbers and lowercase letters!") --ylsp
        return
    else
        TipsCtrl.Instance:ShowSystemMsg("Unknown error, please contact customer service.") --ylsp
        return
    end
end)
		
	end
	--密码验证结束
end

function AgentView:OnClickLoginDown()
	LoginCtrl.Instance:SetLoginButtonIsActive(false)
end

function AgentView:OnClickLoginUp()
	LoginCtrl.Instance:SetLoginButtonIsActive(true)
end
require("game/vip/recharge_data")
RechargeCtrl = RechargeCtrl or BaseClass(BaseController)

-- Require the IAPManager module
    local IAPManager = require("IAPManager")  -- Replace "IAPManager" with your actual module name

-- Create an instance of IAPManager
    local iap_Manager = IAPManager.New()  -- Create a new instance
-- Add functions and logic related to IAPManager
	iap_Manager:Initialize()
    -- Initialization logic for in-app purchases

function RechargeCtrl:__init()
	if RechargeCtrl.Instance then
		print_error("[RechargeCtrl] Attemp to create a singleton twice !")
	end
	RechargeCtrl.Instance = self
	self.data = RechargeData.New()
	self:RegisterProtocol(SCChongZhiInfo, "OnSCChongZhiInfo")
	self.chongzhi_protocol = {}
	self.chongzhi_protocol.today_recharge = 0
end

function RechargeCtrl:__delete()
	RechargeCtrl.Instance = nil
	self.data:DeleteMe()
	self.chongzhi_protocol = nil
end

function RechargeCtrl:GetData()
	return self.data
end

--充值信息返回
function RechargeCtrl:OnSCChongZhiInfo(protocol)
	local is_act_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_DAILY_LOVE)
	local level_open = ActivityData.Instance:GetIsOpenLevel(ACTIVITY_TYPE.RAND_DAILY_LOVE)

	if is_act_open and level_open and protocol.today_recharge then
		MainUICtrl.Instance:FlushTipsIcon(MainUIViewChat.IconList.DailyLove, protocol.today_recharge <= 0)
	end

	self.chongzhi_protocol = protocol
	DailyChargeData.Instance:OnSCChongZhiInfo(protocol)
	self.data:SetChongZhi7DayFetchReward(protocol)
	local first_charge_view = FirstChargeContentView.Instance
	local daily_charge_view = DailyChargeContentView.Instance
	if daily_charge_view ~= nil then
		daily_charge_view:FlushBtnState()
	end

	RemindManager.Instance:Fire(RemindName.Recharge)
	RemindManager.Instance:Fire(RemindName.SupremeMembers)
	RemindManager.Instance:Fire(RemindName.MonthInvest)
	
	ViewManager.Instance:FlushView(ViewName.VipView)
	ViewManager.Instance:FlushView(ViewName.Main, "jubaopen")
	ViewManager.Instance:FlushView(ViewName.Main, "reminder_charge")
	ViewManager.Instance:FlushView(ViewName.Main, "recharge")
	FirstChargeCtrl.Instance:FlusView()
	DailyChargeCtrl.Instance:FlusView()
	LeiJiRDailyCtrl.Instance:FlusView()
	KaifuActivityCtrl.Instance:FlushView()
	LeiJiRDailyCtrl.Instance:SetLeijiViewNextCurrentIndex()

	if not self.is_first_open_charge then
		FirstChargeCtrl.Instance:OpenView()
		self.is_first_open_charge = true
	end
end

--Receive recharge rewards
function RechargeCtrl:SendChongzhiFetchReward(type, param, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSChongzhiFetchReward)
	protocol.type = type
	protocol.param = param --seq
	protocol.param2 = param2 --CHONGZHI_REWARD_TYPE_DAILYindicates the selected reward index
	protocol:EncodeAndSend()
end

--top up
function RechargeCtrl:Recharge(id, money)
	-- Recharge is prohibited when it is determined that recharge is not allowed.
	local open_chongzhi = GLOBAL_CONFIG.param_list.switch_list.open_chongzhi
	if not open_chongzhi then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.ChongZhiError)
		return
	end
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind("当前为跨服场景，无法充值")
		return
	end
	if id then
        -- Pass the id to AgentAdapterBase:PurchaseItem()
        AgentAdapterBase.PurchaseItem(id, money)
    else
        SysMsgCtrl.Instance:ErrorRemind("Recharge operation failed!")
    end
end

--Get 7 days rebate
function RechargeCtrl:SendChongZhi7DayFetchReward()
	local protocol = ProtocolPool.Instance:GetProtocol(CSChongZhi7DayFetchReward)
	protocol:EncodeAndSend()
end


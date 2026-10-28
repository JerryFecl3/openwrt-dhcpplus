'use strict';
'require form';
'require network';

return network.registerProtocol('dhcpplus', {
    getI18n: function() { return _('DHCP+'); },

    renderFormOptions: function(s) {
        // interfaces.js recreates the common option after this protocol hook.
        // Set its default only once all options exist; explicit UCI values win.
        if (!s._dhcpplusRouteDefault) {
            var render = s.render;
            s.render = function() {
                var route = this.getOption('defaultroute');
                if (route) { route.default = '0'; route.rmempty = false; }
                return render.apply(this, arguments);
            };
            s._dhcpplusRouteDefault = true;
        }
        var o;
        o = s.taboption('general', form.DummyValue, '_dhcpplus_help', _('认证方式'));
        o.default = _('使用原装 DHCP 客户端，每次接口启动自动生成随机 XID 和匹配的 Option60，无需手工填写。仅适用于兼容此认证算法的线路。旧固定 XID、Option60 和 vendorid 在运行时忽略。请在设备设置中配置盒子的 MAC，保持原盒子离线。');

        o = s.taboption('advanced', form.Value, 'hostname', _('发送的主机名（可选）'));
        o.default = '*';
        o.description = _('留空或选择 * 不发送 Option12；也可填写普通主机名。本线路已验证无需固定为盒子序列号。旧十六进制 Option12 将忽略。');
        o.value('*', _('不发送主机名'));
        o.datatype = 'or(hostname, "*")';

        o = s.taboption('advanced', form.ListValue, 'sendclientid', _('客户端标识 Option61'));
        o.value('none', _('不发送'));
        o.value('hardware', _('网卡 MAC'));
        o.value('auto', _('自动 / 自定义'));
        o.value('global', _('全局 DUID'));
        o.default = 'none';
        o = s.taboption('advanced', form.Value, 'clientid', _('自定义客户端标识'));
        o.datatype = 'hexstring';
        o.depends('sendclientid', 'auto');

        o = s.taboption('advanced', form.Flag, 'broadcast', _('请求广播回复'));
        o.default = '0';
        o = s.taboption('advanced', form.Flag, 'defaultreqopts', _('请求客户端默认选项'));
        o.default = '0';
        o = s.taboption('advanced', form.Value, 'reqopts', _('请求的 DHCP 选项'));
        o.default = '1 3 6 12 15 28 31 33';
        o.description = _('用空格分隔选项编号。仅在运营商有要求时调整。');
        o.datatype = 'list(range(1,254))';
        o = s.taboption('advanced', form.Flag, 'classlessroute', _('请求无类别静态路由 Option121'));
        o.default = '0';
        o = s.taboption('advanced', form.ListValue, 'iface6rd', _('请求 6rd Option212'));
        o.value('0', _('禁用'));
        o.value('1', _('启用'));
        o.default = '0';
        o = s.taboption('advanced', form.Flag, 'peerdns', _('使用 DHCP 下发的 DNS'));
        o.description = _('IPTV 专网通常保持关闭，以免覆盖管理网络的 DNS。');
        o.default = '0';
        o.rmempty = false;
    }
});

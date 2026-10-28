include $(TOPDIR)/rules.mk

PKG_NAME:=luci-proto-dhcpplus
PKG_VERSION:=0.3.0
PKG_RELEASE:=3
PKG_LICENSE:=MIT
PKGARCH:=all

include $(INCLUDE_DIR)/package.mk

define Package/luci-proto-dhcpplus
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=6. Protocols
  TITLE:=LuCI support for DHCP+ automatic authentication
  DEPENDS:=+luci-base +netifd-proto-dhcpplus
endef

define Build/Compile
endef

define Package/luci-proto-dhcpplus/install
	$(INSTALL_DIR) $(1)/www/luci-static/resources/protocol
	$(INSTALL_DATA) ./htdocs/luci-static/resources/protocol/dhcpplus.js $(1)/www/luci-static/resources/protocol/dhcpplus.js
endef

$(eval $(call BuildPackage,luci-proto-dhcpplus))

include $(TOPDIR)/rules.mk

PKG_NAME:=netifd-proto-dhcpplus
PKG_VERSION:=0.3.1
PKG_RELEASE:=1
PKG_LICENSE:=MIT
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/netifd-proto-dhcpplus
  SECTION:=net
  CATEGORY:=Network
  TITLE:=DHCP+ automatic Liaoning authentication support for the stock DHCP client
  DEPENDS:=+libc +busybox +netifd +openssl-util
endef

define Package/netifd-proto-dhcpplus/description
  Per-client XID helper and an additive netifd protocol for OpenWrt 25.12.
  Uses the stock udhcpc and DHCP event scripts; no global library preload.
endef

define Build/Prepare
	$(INSTALL_DIR) $(PKG_BUILD_DIR)
	$(CP) ./src/udhcpc-xid.c $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_CPPFLAGS) -shared -fPIC \
		-Wall -Wextra $(TARGET_LDFLAGS) \
		-o $(PKG_BUILD_DIR)/udhcpc-xid.so $(PKG_BUILD_DIR)/udhcpc-xid.c
endef

define Package/netifd-proto-dhcpplus/install
	$(INSTALL_DIR) $(1)/lib/netifd/proto $(1)/usr/lib/iptv
	$(INSTALL_BIN) ./files/dhcpplus.sh $(1)/lib/netifd/proto/dhcpplus.sh
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/udhcpc-xid.so $(1)/usr/lib/iptv/udhcpc-xid.so
endef

$(eval $(call BuildPackage,netifd-proto-dhcpplus))

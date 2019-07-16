MAGISK_MODULE_HOMEPAGE=https://www.nano-editor.org/
MAGISK_MODULE_DESCRIPTION="Small, free and friendly text editor"
MAGISK_MODULE_LICENSE="GPL-2.0"
MAGISK_MODULE_VERSION=4.3
MAGISK_MODULE_SHA256=00d3ad1a287a85b4bf83e5f06cedd0a9f880413682bebd52b4b1e2af8cfc0d81
MAGISK_MODULE_SRCURL=https://nano-editor.org/dist/latest/nano-$MAGISK_MODULE_VERSION.tar.xz
MAGISK_MODULE_DEPENDS="ncurses"
MAGISK_MODULE_EXTRA_CONFIGURE_ARGS="
ac_cv_header_pwd_h=no
--enable-utf8
--with-wordbounds
--datarootdir=/system/etc
"
MAGISK_MODULE_CONFFILES="etc/nanorc"
MAGISK_MODULE_RM_AFTER_INSTALL="bin/rnano share/man/man1/rnano.1 share/nano/man-html"

magisk_step_pre_configure() {
	export PATH=/usr/local/musl/bin:$PATH
	CC=/usr/local/musl/bin/aarch64-linux-musl-gcc
	MAGISK_MODULE_EXTRA_CONFIGURE_ARGS+=" --host=aarch64-linux-musl --target=aarch64-linux-musl"
	LDFLAGS+=" --static"
	if [ "$MAGISK_DEBUG" == "true" ]; then
		# When doing debug build, -D_FORTIFY_SOURCE=2 gives this error:
		# /home/builder/.magisk-build/_lib/16-aarch64-21-v3/bin/../sysroot/usr/include/bits/fortify/string.h:79:26: error: use of undeclared identifier '__USE_FORTIFY_LEVEL'
		export CFLAGS=${CFLAGS/-D_FORTIFY_SOURCE=2/}
	fi
}

magisk_step_post_make_install() {
	# Configure nano to use syntax highlighting:
	rm -Rf $MAGISK_MODULE_MASSAGEDIR/system/etc/doc
	NANORC=$MAGISK_PREFIX/etc/nanorc
	echo include \"$MAGISK_PREFIX/etc/nano/\*nanorc\" > $NANORC
}

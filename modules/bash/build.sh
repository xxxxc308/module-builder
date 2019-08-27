MAGISK_MODULE_HOMEPAGE=https://www.gnu.org/software/bash/
MAGISK_MODULE_DESCRIPTION="A sh-compatible shell that incorporates useful features from the Korn shell (ksh) and C shell (csh)"
MAGISK_MODULE_LICENSE="GPL-3.0"
_MAIN_VERSION=5.0
_PATCH_VERSION=9
MAGISK_MODULE_VERSION=${_MAIN_VERSION}.${_PATCH_VERSION}
MAGISK_MODULE_REVISION=5
MAGISK_MODULE_SRCURL=https://mirrors.kernel.org/gnu/bash/bash-${_MAIN_VERSION}.tar.gz
MAGISK_MODULE_SHA256=b4a80f2ac66170b2913efbfb9f2594f1f76c7b1afd11f799e22035d63077fb4d
MAGISK_MODULE_DEPENDS="libandroid-support, ncurses, readline (>= 8.0)"
MAGISK_MODULE_RECOMMENDS="command-not-found"
MAGISK_MODULE_BREAKS="bash-dev"
MAGISK_MODULE_REPLACES="bash-dev"
MAGISK_MODULE_ESSENTIAL=true
MAGISK_MODULE_BUILD_IN_SRC=true

MAGISK_MODULE_EXTRA_CONFIGURE_ARGS="--enable-multibyte --without-bash-malloc --with-installed-readline --enable-static-link"
MAGISK_MODULE_EXTRA_CONFIGURE_ARGS+=" bash_cv_job_control_missing=present"
MAGISK_MODULE_EXTRA_CONFIGURE_ARGS+=" bash_cv_sys_siglist=yes"
MAGISK_MODULE_EXTRA_CONFIGURE_ARGS+=" bash_cv_func_sigsetjmp=present"
MAGISK_MODULE_EXTRA_CONFIGURE_ARGS+=" bash_cv_unusable_rtsigs=no"
MAGISK_MODULE_EXTRA_CONFIGURE_ARGS+=" ac_cv_func_mbsnrtowcs=no"
# Use bash_cv_dev_fd=whacky to use /proc/self/fd instead of /dev/fd.
# After making this change process substitution such as in 'cat <(ls)' works.
MAGISK_MODULE_EXTRA_CONFIGURE_ARGS+=" bash_cv_dev_fd=whacky"
# Bash assumes that getcwd is broken and provides a wrapper which
# does not work when not all parent directories up to root are
# accessible, which they are not under Android (/data). See
# - http://permalink.gmane.org/gmane.linux.embedded.yocto.general/25204
# - https://github.com/termux/termux-app/issues/200
MAGISK_MODULE_EXTRA_CONFIGURE_ARGS+=" bash_cv_getcwd_malloc=yes"

MAGISK_MODULE_CONFFILES="etc/bash.bashrc etc/profile"

MAGISK_MODULE_RM_AFTER_INSTALL="usr/share/man/man1/bashbug.1 bin/bashbug"

magisk_step_pre_configure() {
	declare -A PATCH_CHECKSUMS

	PATCH_CHECKSUMS[001]=f2fe9e1f0faddf14ab9bfa88d450a75e5d028fedafad23b88716bd657c737289
	PATCH_CHECKSUMS[002]=87e87d3542e598799adb3e7e01c8165bc743e136a400ed0de015845f7ff68707
	PATCH_CHECKSUMS[003]=4eebcdc37b13793a232c5f2f498a5fcbf7da0ecb3da2059391c096db620ec85b
	PATCH_CHECKSUMS[004]=14447ad832add8ecfafdce5384badd933697b559c4688d6b9e3d36ff36c62f08
	PATCH_CHECKSUMS[005]=5bf54dd9bd2c211d2bfb34a49e2c741f2ed5e338767e9ce9f4d41254bf9f8276
	PATCH_CHECKSUMS[006]=d68529a6ff201b6ff5915318ab12fc16b8a0ebb77fda3308303fcc1e13398420
	PATCH_CHECKSUMS[007]=17b41e7ee3673d8887dd25992417a398677533ab8827938aa41fad70df19af9b
	PATCH_CHECKSUMS[008]=eec64588622a82a5029b2776e218a75a3640bef4953f09d6ee1f4199670ad7e3
        PATCH_CHECKSUMS[009]=ed3ca21767303fc3de93934aa524c2e920787c506b601cc40a4897d4b094d903

	for PATCH_NUM in $(seq -f '%03g' ${_PATCH_VERSION}); do
		PATCHFILE=$MAGISK_MODULE_CACHEDIR/bash_patch_${PATCH_NUM}.patch
		magisk_download \
			"https://mirrors.kernel.org/gnu/bash/bash-${_MAIN_VERSION}-patches/bash${_MAIN_VERSION/./}-$PATCH_NUM" \
			$PATCHFILE \
			${PATCH_CHECKSUMS[$PATCH_NUM]}
		patch -p0 -i $PATCHFILE
	done
	unset PATCH_CHECKSUMS PATCHFILE PATCH_NUM
}

magisk_step_post_make_install() {
	sed -e "s|@MAGISK_PREFIX@|$MAGISK_PREFIX|" \
		-e "s|@MAGISK_HOME@|$MAGISK_ANDROID_HOME|" \
		$MAGISK_MODULE_BUILDER_DIR/etc-profile > $MAGISK_PREFIX/etc/profile

	# /etc/bash.bashrc - System-wide .bashrc file for interactive shells. (config-top.h in bash source, patched to enable):
	sed -e "s|@MAGISK_PREFIX@|$MAGISK_PREFIX|" \
		-e "s|@MAGISK_HOME@|$MAGISK_ANDROID_HOME|" \
		$MAGISK_MODULE_BUILDER_DIR/etc-bash.bashrc > $MAGISK_PREFIX/etc/bash.bashrc
}

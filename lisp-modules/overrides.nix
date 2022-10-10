{ pkgs, lib }:

scope:

let
  hdf5_1_10_5 = pkgs.callPackage ./non-lisp/hdf5/hdf5-1.10.5.nix {
    fortranSupport = false;
    fortran = pkgs.gfortran;
  };
in
scope.overrideScope' (self: super: rec {

  "2d-array" = super."2d-array".overrideAttrs (oa: {
    extraFiles = "version.lisp";
  });

  "40ants-doc-full" = super."40ants-doc-full".overrideAttrs (oa: {
    extraFiles = [ "40ants-doc.asd" ];
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.openssl.out ];
    postInstall = ''
      rm $out/share/common-lisp/source-registry.conf.d/$(stripHash ${self."40ants-doc"}).conf
      rm $out/share/common-lisp/asdf-output-translations.conf.d/$(stripHash ${self."40ants-doc"}).conf
    '';
  });

  cffi-libffi = super.cffi-libffi.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [
      pkgs.libffi_3_3.out pkgs.libffi_3_3.dev
    ];
  });

  cl-ana_dot_hdf-cffi = super.cl-ana_dot_hdf-cffi.overrideAttrs (oa:
  {
    buildInputs = oa.buildInputs ++ [ pkgs.pkg-config ];
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ hdf5_1_10_5 hdf5_1_10_5.dev ];
  });

  cl-ana_dot_hdf-table = super.cl-ana_dot_hdf-table.overrideAttrs (oa:
  {
    buildInputs = oa.buildInputs ++ [ pkgs.pkg-config ];
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ hdf5_1_10_5 hdf5_1_10_5.dev ];
  });

  cl-async-ssl = super.cl-async-ssl.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.libuv pkgs.openssl.out ];
  });

  cl-cffi-gtk-cairo = super.cl-cffi-gtk-cairo.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.cairo ];
  });

  cl-cffi-gtk-gdk = super.cl-cffi-gtk-gdk.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.gtk3 ];
  });

  cl-cffi-gtk-gdk-pixbuf = super.cl-cffi-gtk-gdk-pixbuf.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.gdk-pixbuf ];
  });

  cl-cffi-gtk-glib = super.cl-cffi-gtk-glib.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.glib.out ];
  });

  cl-cffi-gtk-pango = super.cl-cffi-gtk-pango.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.gnome2.pango.out ];
  });

  cl-containers = super.cl-containers.overrideAttrs (oa: {
    lispInputs = oa.lispInputs ++ (with self; [ asdf-system-connections ]);
  });

  cl-cuda = super.cl-cuda.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [
      # TODO: libcuda.so
    ];
  });

  cl-gobject-introspection = super.cl-gobject-introspection.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [
      pkgs.glib.out
      pkgs.gobject-introspection
    ];
  });

  cl-gopher = super.cl-gopher.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.openssl.out ];
  });

  cl-libuv = super.cl-libuv.overrideAttrs (oa: {
    lispInputs = oa.lispInputs ++ [ self.cffi-grovel ];
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.libuv ];
  });

  cl_plus_ssl_merged = super.cl_plus_ssl_merged.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.openssl.out ];
  });

  cl-tld = super.cl-tld.overrideAttrs (oa: {
    extraFiles = [ "effective_tld_names.dat" ];
  });

  cl-unicode = super.cl-unicode.overrideAttrs (oa: {
    lispInputs = oa.lispInputs ++ [ super.flexi-streams ];
    extraFiles = [ "build" "test" ];
  });

  cl-webkit2 = super.cl-webkit2.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ (with pkgs; [
      glib.out gdk-pixbuf cairo gnome2.pango.out gtk3 webkitgtk_4_1
    ]);
  });

  commondoc-markdown-docs = super.commondoc-markdown-docs.overrideAttrs (oa: {
    lispInputs = oa.lispInputs ++ [ self.commondoc-markdown ];
  });

  gsll = super.gsll.overrideAttrs (oa: {
    lispInputs = oa.lispInputs ++ [ cffi-libffi ];
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.gsl ];
});

  iolib_merged = super.iolib_merged.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.libfixposix ];
  });

  lla = super.lla.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.openblas ];
  });

  nfiles = super.nfiles.overrideAttrs (oa: {
    lispInputs = oa.lispInputs ++ [ self.iolib_slash_os ];
  });

  ## Nyxt Browser
  nyxt-gtk = super.nyxt_slash_gtk-application.overrideAttrs (oa: rec {
    pname = "nyxt-gtk";

    providedSystems = [ "nyxt/gtk-application" ];
    systemFiles = [ "nyxt.asd" "source/." "libraries/." ];

    application = "nyxt/gtk-application";

    extraCompilerArgs = if oa.compiler.pname == "sbcl"
                        then [ "--dynamic-space-size"
                               "$(sbcl --noinform --no-userinit --non-interactive --eval '(prin1 (max 3072 (/ (sb-ext:dynamic-space-size) 1024 1024)))' --quit | tail -1)" ]
                        else [];

    nativeBuildInputs = oa.nativeBuildInputs ++ (with pkgs; [
      makeWrapper wrapGAppsHook
    ]);

    lispInputs = (lib.remove self.cl-containers oa.lispInputs) ++ [
      self.alexandria
      self.cl-gobject-introspection
      self.mk-string-metrics
      self.osicat
      (cl-containers.override { preLoad = with self; [
                                  moptilities metatilities-base
                                ]; })
    ];

    gstBuildInputs = with pkgs.gst_all_1; [
      gstreamer gst-libav
      gst-plugins-base
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
    ];

    buildInputs = oa.buildInputs ++ (with pkgs; [
      mailcap glib-networking gsettings-desktop-schemas xclip notify-osd enchant
    ]) ++ gstBuildInputs;

    GST_PLUGIN_SYSTEM_PATH_1_0 = pkgs.lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstBuildInputs;

    dontWrapGApps = true;
    installPhase = ''
      mkdir -p $out/share/applications/
      sed "s/VERSION/$version/" $src/assets/nyxt.desktop > $out/share/applications/nyxt.desktop
      for i in 16 32 128 256 512; do
        mkdir -p "$out/share/icons/hicolor/''${i}x''${i}/apps/"
        cp -f $src/assets/nyxt_''${i}x''${i}.png "$out/share/icons/hicolor/''${i}x''${i}/apps/nyxt.png"
      done

      mkdir -p $out/bin && makeWrapper $output/nyxt $out/bin/nyxt \
        --set LD_LIBRARY_PATH "$LD_LIBRARY_PATH" \
        --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${GST_PLUGIN_SYSTEM_PATH_1_0}" \
        --argv0 nyxt "''${gappsWrapperArgs[@]}"
    '';

    checkPhase = ''
      $out/bin/nyxt -h
    '';
  });

  pzmq = super.pzmq.overrideAttrs (oa: {
    lispInputs = oa.lispInputs ++ [ self.cffi-grovel ];
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.zeromq ];
  });

  quri = super.quri.overrideAttrs (oa: {
    extraFiles = [ "data" ];
  });

  swank = super.swank.overrideAttrs (oa: {
    extraFiles = [
      "swank" "contrib" "lib"
      "metering.lisp"
      "nregex.lisp"
      "packages.lisp"
      "sbcl-pprint-patch.lisp"
      "start-swank.lisp"
      "swank-loader.lisp"
      "swank.lisp"
      "xref.lisp"
    ];
  });

  slynk = super.slynk.overrideAttrs (oa: {
    extraFiles = [ "slynk" ];
  });

  trivial-mimes = super.trivial-mimes.overrideAttrs (oa: {
    extraFiles = [ "mime.types" ];
  });

})

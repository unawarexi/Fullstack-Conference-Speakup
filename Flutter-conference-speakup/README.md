i ran this. emulator -avd  pixel-10 -no-snapshot-load. and i got this "acBook-Pro Flutter-conference-speakup % emulator -avd  pixel-10 -no-snapshot-load
INFO         | Android emulator version 36.5.10.0 (build_id 15081367) (CL:N/A)
INFO         | Graphics backend: gfxstream
INFO         | Found systemPath /Users/mac/Library/Android/sdk/system-images/android-37.0/google_apis_playstore_ps16k/x86_64/
WARNING      | Please update the emulator to one that supports the feature(s): VulkanVirtualQueue
INFO         | Increasing RAM size to 3072MB
INFO         | Guest GLES Driver: Auto (ext controls)
INFO         | emuglConfig_init: vulkan_mode_selected:swiftshader gles_mode_selected:host
INFO         | Checking system compatibility:
INFO         |   Checking: hasSufficientDiskSpace
INFO         |      Ok: Disk space requirements to run avd: `pixel-10` are met
INFO         |   Checking: hasSufficientHwGpu
INFO         |      Ok: Hardware GPU compatibility checks are not required
INFO         |   Checking: hasSufficientSystem
INFO         |      Ok: System requirements to run avd: `pixel-10` are met
INFO         | Storing crashdata in: /tmp/android-mac/emu-crash-36.5.10.db, detection is enabled for process: 93978
INFO         | Initializing gfxstream backend
INFO         | android_startOpenglesRenderer: gpu info
INFO         | GPU #1
  Make: 8086
  Model: 8a53
  Device ID: 8a53

INFO         | initIcdPaths: ICD set to 'swiftshader', using Swiftshader ICD
INFO         | Setting ICD filenames for the loader = /Users/mac/Library/Android/sdk/emulator/lib64/vulkan/vk_swiftshader_icd.json
INFO         | SharedLibrary::open for [/Users/mac/Library/Android/sdk/emulator/qemu/darwin-x86_64/lib64/vulkan/libvulkan.dylib]
INFO         | Added library: /Users/mac/Library/Android/sdk/emulator/qemu/darwin-x86_64/lib64/vulkan/libvulkan.dylib
INFO         | Enabling Vulkan portability.
INFO         | Selecting Vulkan device: SwiftShader Device (Subzero), Version: 1.3.0
INFO         | Initializing VkEmulation features:
INFO         |     glInteropSupported: false
INFO         |     useDeferredCommands: true
INFO         |     createResourceWithRequirements: true
INFO         |     useVulkanComposition: false
INFO         |     useVulkanNativeSwapchain: false
INFO         |     enable guestRenderDoc: false
INFO         |     ASTC LDR emulation mode: Gpu
INFO         |     enable ETC2 emulation: true
INFO         |     enable Ycbcr emulation: false
INFO         |     guestVulkanOnly: false
INFO         |     useDedicatedAllocations: false
INFO         |     guestVulkanMaxApiVersion: 1.4.344
INFO         | Graphics Adapter Vendor Google (Intel Inc.)
INFO         | Graphics Adapter Android Emulator OpenGL ES Translator (Intel(R) Iris(TM) Plus Graphics OpenGL Engine)
INFO         | Graphics API Version OpenGL ES 3.0 (4.1 INTEL-24.5.6)
INFO         | Graphics API Extensions GL_OES_EGL_sync GL_OES_EGL_image GL_OES_EGL_image_external GL_OES_depth24 GL_OES_depth32 GL_OES_element_index_uint GL_OES_texture_float GL_OES_texture_float_linear GL_OES_compressed_paletted_texture GL_OES_compressed_ETC1_RGB8_texture GL_OES_depth_texture GL_OES_texture_npot GL_OES_rgb8_rgba8 GL_EXT_color_buffer_float GL_EXT_color_buffer_half_float GL_EXT_texture_format_BGRA8888 GL_APPLE_texture_format_BGRA8888 
INFO         | Graphics Device Extensions N/A
INFO         | Disabling sparse binding feature support
INFO         | Sending adb public key [QAAAAG+nIeVxaODB+SUS1qbvReZ4M/hvTxjCkrnYVvO7cAAttTa8t7SKdSDkmT1P3atkfVWmMh5VoKss/U3ltWu6o678VvGHBztlnHpvXJo/1zY+ZmSpq+51lpZGl3LCcEhPNVDzsE+SDp0qRA8QI2zxw1J7878JB7CH8dYyi6PwWo12nCMVpLERpgMEDmcR3gMEDrER+LA+HueFxbg4OwpS4KrFwaUA/++pq2WfbRmLLrivtKrXCvgb/Xcj84lBt2cK8AzopHSAmB1ehootaT/TwQ+6EAFu5a5uzv2EWkx3/19N7nOFtoogsGMZUTEU14dzHYPpX/gQfhrQUy1tXbtxQxHxiGamJ/XUggXoVqy9EH0Vb+VsNHYWYLGfUEe+oPIj9dHG4N6s6ZHIzBkgXh4List63xuuoioE8ue0Oj6+cJfLnGenCsM+tv5hmCT/i6uEdXieME4hB4FjJtTucA1fXkkftHJG5daaNcczY+LS/8FRpgZ7/Ehazp3SgH1bQixTaSWtihV6J1gh1B4gL9L8kJ862SbS6bHGf+RIo1i8LVxIP7mMX/9yfmdglIXkvsrMeKDwbSkE9n/Ml1a+SoJm2YJg4dzby1DtpKwx5nL+rZUEx0CZdqNOvGTc+QJWMmqhpERYJMol6Ge5WMHwTsP+AKXPXpeQlnwVxpOp0fRaU3C4qOr1mQEAAQA= mac@unknown]
INFO         | Userspace boot properties:
INFO         |   androidboot.boot_devices=pci0000:00/0000:00:03.0 pci0000:00/0000:00:06.0
INFO         |   androidboot.dalvik.vm.heapsize=576m
INFO         |   androidboot.debug.hwui.renderer=skiagl
INFO         |   androidboot.hardware=ranchu
INFO         |   androidboot.hardware.gltransport=pipe
INFO         |   androidboot.hardware.vulkan=ranchu
INFO         |   androidboot.logcat=*:V
INFO         |   androidboot.opengles.version=196608
INFO         |   androidboot.qemu=1
INFO         |   androidboot.qemu.adb.pubkey=QAAAAG+nIeVxaODB+SUS1qbvReZ4M/hvTxjCkrnYVvO7cAAttTa8t7SKdSDkmT1P3atkfVWmMh5VoKss/U3ltWu6o678VvGHBztlnHpvXJo/1zY+ZmSpq+51lpZGl3LCcEhPNVDzsE+SDp0qRA8QI2zxw1J7878JB7CH8dYyi6PwWo12nCMVpLERpgMEDmcR3gMEDrER+LA+HueFxbg4OwpS4KrFwaUA/++pq2WfbRmLLrivtKrXCvgb/Xcj84lBt2cK8AzopHSAmB1ehootaT/TwQ+6EAFu5a5uzv2EWkx3/19N7nOFtoogsGMZUTEU14dzHYPpX/gQfhrQUy1tXbtxQxHxiGamJ/XUggXoVqy9EH0Vb+VsNHYWYLGfUEe+oPIj9dHG4N6s6ZHIzBkgXh4List63xuuoioE8ue0Oj6+cJfLnGenCsM+tv5hmCT/i6uEdXieME4hB4FjJtTucA1fXkkftHJG5daaNcczY+LS/8FRpgZ7/Ehazp3SgH1bQixTaSWtihV6J1gh1B4gL9L8kJ862SbS6bHGf+RIo1i8LVxIP7mMX/9yfmdglIXkvsrMeKDwbSkE9n/Ml1a+SoJm2YJg4dzby1DtpKwx5nL+rZUEx0CZdqNOvGTc+QJWMmqhpERYJMol6Ge5WMHwTsP+AKXPXpeQlnwVxpOp0fRaU3C4qOr1mQEAAQA= mac@unknown
INFO         |   androidboot.qemu.avd_name=pixel-10
INFO         |   androidboot.qemu.camera_hq_edge_processing=0
INFO         |   androidboot.qemu.camera_protocol_ver=1
INFO         |   androidboot.qemu.cpuvulkan.version=4202496
INFO         |   androidboot.qemu.gltransport.drawFlushInterval=800
INFO         |   androidboot.qemu.gltransport.name=pipe
INFO         |   androidboot.qemu.hwcodec.avcdec=2
INFO         |   androidboot.qemu.hwcodec.hevcdec=2
INFO         |   androidboot.qemu.hwcodec.vpxdec=2
INFO         |   androidboot.qemu.settings.system.screen_off_timeout=2147483647
INFO         |   androidboot.qemu.skin=pixel_10_pro_xl
INFO         |   androidboot.qemu.virtiowifi=1
INFO         |   androidboot.qemu.vsync=60
INFO         |   androidboot.serialno=EMULATOR36X5X10X0
INFO         |   androidboot.vbmeta.digest=494ad6b67f7783f71d180a15ea0706825322d7a77e7ca130502c76c191c3d148
INFO         |   androidboot.vbmeta.hash_alg=sha256
INFO         |   androidboot.vbmeta.size=6848
INFO         |   androidboot.veritymode=enforcing
INFO         | Monitoring duration of emulator setup.
WARNING      | The emulator now requires a signed jwt token for gRPC access! Use the -grpc flag if you really want an open unprotected grpc port
INFO         | Using security allow list from: /Users/mac/Library/Android/sdk/emulator/lib/emulator_access.json
WARNING      | *** Basic token auth should only be used by android-studio ***
INFO         | The active JSON Web Key Sets can be found here: /Users/mac/Library/Caches/TemporaryItems/avd/running/93978/jwks/dcaba7c4-99c1-44aa-9fc2-f89270568807/active.jwk
INFO         | Scanning /Users/mac/Library/Caches/TemporaryItems/avd/running/93978/jwks/dcaba7c4-99c1-44aa-9fc2-f89270568807 for jwk keys.
INFO         | Started GRPC server at 127.0.0.1:8554, security: Local, auth: +token
INFO         | Advertising in: /Users/mac/Library/Caches/TemporaryItems/avd/running/pid_93978.ini
INFO         | Activated packet streamer for uwb emulation
INFO         | Successfully initialized netsim WiFi
INFO         | Activated packet streamer for bluetooth emulation
INFO         | Setting display: 0 configuration to: 1344x2992, dpi: 480x480 
INFO         | setDisplayActiveConfig: id:0, 1344x2992
INFO         | emulatorSetupEnvironment: Setting up screen background view and display layout at env:1344x2992, lcd:1344x2992
WARNING      | getEnvironmentConfig: No environment config is provided
INFO         | getEnvironmentConfig: Using default virtual scene contents for the environment.
INFO         | Checking system compatibility:
INFO         |   Checking: hasSufficientDiskSpace
INFO         |      Ok: Disk space requirements to run avd: `pixel-10` are met
INFO         |   Checking: hasSufficientHwGpu
INFO         |      Ok: Hardware GPU compatibility checks are not required
INFO         |   Checking: hasSufficientSystem
INFO         |      Ok: System requirements to run avd: `pixel-10` are met
USER_INFO    | Emulator is performing a full startup. This may take upto two minutes, or more.
INFO         | GPU Vendor=[Google (Intel Inc.)]
INFO         | GPU Renderer=[Android Emulator OpenGL ES Translator (Intel(R) Iris(TM) Plus Graphics OpenGL Engine)]
INFO         | GPU Version=[OpenGL ES 3.0 (4.1 INTEL-24.5.6)]
INFO         | Warning: QMetaObject::connectSlotsByName: No matching signal for on_rgbcSensorValueWidget_valueChanged() (:0, )
INFO         | Warning: QMetaObject::connectSlotsByName: No matching signal for on_posture_valueChanged(int) (:0, )
INFO         | Warning: QObject::connect: Cannot queue arguments of type 'std::vector<android::emulation::control::SnapshotInfo>'
(Make sure 'std::vector<android::emulation::control::SnapshotInfo>' is registered using qRegisterMetaType().) (:0, )
INFO         | AVD supportsNativeGLES=1, supportsGuestAngle=0
INFO         | Platform does not support Guest Angle
INFO         | Warning: QObject::connect: No such signal ToolWindow::microphoneEnabledChanged() in /Volumes/Android/buildbot/src/googleplex-android/emu-36-5-release/external/qemu/android/android-ui/modules/aemu-ui-qt/src/android/skin/qt/extended-window.cpp:160 (:0, )
INFO         | Warning: QObject::connect:  (sender name:   'ToolControls') (:0, )
INFO         | Warning: QObject::connect:  (receiver name: 'microphonePage') (:0, )
INFO         | Warning: QObject::connect: No such signal MicrophonePage::microphoneEnabledChanged() in /Volumes/Android/buildbot/src/googleplex-android/emu-36-5-release/external/qemu/android/android-ui/modules/aemu-ui-qt/src/android/skin/qt/extended-window.cpp:162 (:0, )
INFO         | Warning: QObject::connect:  (sender name:   'microphonePage') (:0, )
INFO         | Warning: QObject::connect:  (receiver name: 'ToolControls') (:0, )
INFO         | Created extended window in 666.733ms
INFO         | Warning: skipping QEventPoint(id=1 ts=0 pos=0,0 scn=485.845,208.601 gbl=485.845,208.601 Released ellipse=(1x1 ∡ 0) vel=0,0 press=-485.845,-208.601 last=-485.845,-208.601 Δ 485.845,208.601) : no target window (:0, )
WARNING      | adb command '/Users/mac/Library/Android/sdk/platform-tools/adb -s emulator-5554 shell getprop sys.boot_completed ' failed: 'adb: device offline'
WARNING      | adb command '/Users/mac/Library/Android/sdk/platform-tools/adb -s emulator-5554 shell getprop sys.boot_completed ' failed: 'adb: device offline'
WARNING      | adb command '/Users/mac/Library/Android/sdk/platform-tools/adb -s emulator-5554 shell getprop sys.boot_completed ' failed: 'adb: device offline'
WARNING      | adb command '/Users/mac/Library/Android/sdk/platform-tools/adb -s emulator-5554 shell getprop sys.boot_completed ' failed: 'adb: device offline'
WARNING      | adb command '/Users/mac/Library/Android/sdk/platform-tools/adb -s emulator-5554 shell getprop sys.boot_completed ' failed: 'adb: device offline'
WARNING      | adb command '/Users/mac/Library/Android/sdk/platform-tools/adb -s emulator-5554 shell getprop sys.boot_completed ' failed: 'adb: device offline'
WARNING      | adb command '/Users/mac/Library/Android/sdk/platform-tools/adb -s emulator-5554 shell getprop sys.boot_completed ' failed: 'adb: device offline'
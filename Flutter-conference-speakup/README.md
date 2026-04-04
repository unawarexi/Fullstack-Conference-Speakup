e: file:///Users/mac/Desktop/MY/Fullstack-Conference-Speakup/Flutter-conference-speakup/android/app/build.gradle.kts:14:37: Unexpected tokens (use ';' to separate expressions on the same line)
e: file:///Users/mac/Desktop/MY/Fullstack-Conference-Speakup/Flutter-conference-speakup/android/app/build.gradle.kts:14:9: Unresolved reference: coreLibraryDesugaringEnabled

FAILURE: Build failed with an exception.

* Where:
Build file '/Users/mac/Desktop/MY/Fullstack-Conference-Speakup/Flutter-conference-speakup/android/app/build.gradle.kts' line: 14

* What went wrong:
Script compilation errors:

  Line 14:         coreLibraryDesugaringEnabled true
                                               ^ Unexpected tokens (use ';' to separate expressions on the same line)

  Line 14:         coreLibraryDesugaringEnabled true
                   ^ Unresolved reference: coreLibraryDesugaringEnabled

  Line 14:         coreLibraryDesugaringEnabled true
                                                ^ The expression is unused

  Line 20:         jvmTarget = JavaVersion.VERSION_17.toString()
                   ^ 'jvmTarget: String' is deprecated. Please migrate to the compilerOptions DSL. More details are here: https://kotl.in/u1r8ln

4 errors

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 5s
Running Gradle task 'assembleDebug'...                              5.4s
Error: Gradle task assembleDebug failed with exit code 1
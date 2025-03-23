allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprocess {
    val newSubprocessBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprocessBuildDir)
}
subprocess {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

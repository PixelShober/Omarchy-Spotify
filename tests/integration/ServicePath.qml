import QtQuick
import Quickshell
ShellRoot {
  id: root
  property var service: null
  Component.onCompleted: {
    var dir = Quickshell.env("OMARCHY_SPOTIFY_TEST_PLUGIN_DIR")
    if (!dir) { console.log("SERVICE_PATH_FAIL: set OMARCHY_SPOTIFY_TEST_PLUGIN_DIR"); Qt.quit(); return }
    var component = Qt.createComponent("file://" + dir + "/Service.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) { console.log("SERVICE_PATH_FAIL", component.errorString()); Qt.quit(); return }
    service = component.createObject(root, {manifest: {id: "quickshell.spotify"}})
    service.daemon.automaticSetupAttempted = true
  }
  Timer {
    interval: 1500; running: true
    onTriggered: {
      console.log("CHECK", JSON.stringify({pluginDir: service.pluginDir, requirementsChecked: service.daemon.requirementsChecked, credentialsChecked: service.daemon.credentialsChecked, setupBusy: service.daemon.setupBusy, playbackReady: service.daemon.playbackReady, loginBusy: service.loginBusy}))
      if (!service.pluginDir || !service.daemon.requirementsChecked || !service.daemon.credentialsChecked) throw new Error("Playback checks never completed")
      console.log("SERVICE_PATH_PASS")
      Qt.quit()
    }
  }
}

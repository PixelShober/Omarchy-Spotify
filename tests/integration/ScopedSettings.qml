import QtQuick
import Quickshell
ShellRoot {
  id: root
  QtObject {
    id: facade
    property var barConfig: ({layout: {right: [{id: "quickshell.spotify", clientId: "11111111111111111111111111111111"}]}})
  }
  property var service: null
  Component.onCompleted: {
    var dir = Quickshell.env("OMARCHY_SPOTIFY_TEST_PLUGIN_DIR")
    if (!dir) { console.log("SCOPED_SETTINGS_FAIL: set OMARCHY_SPOTIFY_TEST_PLUGIN_DIR"); Qt.quit(); return }
    var component = Qt.createComponent("file://" + dir + "/Service.qml", Component.PreferSynchronous)
    if (component.status !== Component.Ready) { console.log("SCOPED_SETTINGS_FAIL", component.errorString()); Qt.quit(); return }
    service = component.createObject(root, {shell: facade, manifest: {id: "quickshell.spotify", __sourceDir: dir}})
    service.daemon.automaticSetupAttempted = true
  }
  Timer {
    interval: 500; running: true
    onTriggered: {
      if (service.settings.clientId !== "11111111111111111111111111111111"
          || service.auth.resolvedClientId !== service.settings.clientId) {
        console.log("SCOPED_SETTINGS_FAIL: configured client was lost at startup")
        Qt.quit(); return
      }
      facade.barConfig = {layout: {right: [{id: "quickshell.spotify", clientId: "22222222222222222222222222222222"}]}}
      updated.start()
    }
  }
  Timer {
    id: updated; interval: 100
    onTriggered: {
      if (service.settings.clientId !== "22222222222222222222222222222222"
          || service.auth.resolvedClientId !== service.settings.clientId)
        console.log("SCOPED_SETTINGS_FAIL: live config change was ignored")
      else console.log("SCOPED_SETTINGS_PASS")
      Qt.quit()
    }
  }
}

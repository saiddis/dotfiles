import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Item {
  id: root

  property string backgroundPath: ""
  property string videoPosterPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool fingerprintUnavailable: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool loadBackground: true
  property string passwordText: ""
  property bool syncingPasswordText: false

  readonly property string placeholderText: Commons.I18n.t("lock.enterPassword")
  readonly property int fieldWidth: 381
  readonly property int fieldHeight: 67
  readonly property int outlineThickness: 3
  readonly property int fieldFontSize: Math.round(Style.font.heading * 1.125)
  readonly property int passwordDotFontSize: Math.round(Style.font.heading * 1.33)
  readonly property int passwordDotLetterSpacing: Math.round(Style.font.heading * 0.19)
  // Space to keep clear on each side of the field for the fingerprint icon
  // (icon width plus a gap) so the centered dots never run under it.
  readonly property real fingerprintReserve: fingerprintConfigured ? Math.round(fingerprintIcon.implicitWidth + 12) : 0
  // Shrink the dots to fit once the password outgrows the field, so every
  // keystroke stays visible — otherwise long passwords clip with no feedback.
  readonly property real passwordDotScale: dotMetrics.advanceWidth > 0
    ? Math.min(1, (passwordInput.width - 4) / dotMetrics.advanceWidth)
    : 1
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && failureMessage.length === 0
  readonly property bool errorState: failureMessage.length > 0
  readonly property var inputBorderSpec: errorState
    ? Border.surfaceSpec("lock", "border-error", Commons.Color.lock.borderError, root.outlineThickness, "border-alpha")
    : Border.surfaceSpec("lock", "border-active", Commons.Color.lock.borderActive, root.outlineThickness, "border-alpha")

  // A video wallpaper shows its still poster: nothing plays behind the lock.
  readonly property bool video: Util.isVideoPath(root.backgroundPath)

  // Moonfly look: a quiet near-black screen, a large clock, and a Neovim
  // statusline whose mode pill follows the lock: LOCKED at rest, INSERT while
  // typing, CHECK while the password is checked, ERROR after a wrong one.
  // Colours come from the theme's [lock] section (extra keys written by the
  // Moonfly theme's sync-overrides.py); other themes fall back to their own
  // accent and error colours.
  function themed(key, fallback) {
    var v = Commons.Color.shellValues["lock." + key]
    return v ? Commons.Color.flatColor(v, fallback) : fallback
  }
  readonly property color clockColor: themed("clock", Commons.Color.lock.text)
  readonly property color dateColor: themed("date", Commons.Color.lock.placeholder)
  readonly property color statuslineColor: themed("statusline", Commons.Color.lock.background)
  readonly property color modeTextColor: themed("mode-text", Commons.Color.background)
  readonly property string mode: errorState ? "ERROR"
    : authenticatingPassword ? "CHECK"
    : passwordInput.text.length > 0 ? "INSERT"
    : "LOCKED"
  readonly property color modeColor: errorState ? themed("mode-error", Commons.Color.lock.textError)
    : authenticatingPassword ? themed("mode-command", Commons.Color.accent)
    : passwordInput.text.length > 0 ? themed("mode-insert", Commons.Color.accent)
    : themed("mode-normal", Commons.Color.accent)
  readonly property int clockFontSize: Math.round(Style.font.display * 5)
  readonly property int statuslineHeight: Math.round(Style.font.body * 2.25)
  readonly property var battery: UPower.displayDevice
  readonly property bool batteryPresent: !!(battery && battery.isPresent && battery.isLaptopBattery)
  readonly property int batteryLevel: batteryPresent ? Math.round(Number(battery.percentage || 0) * 100) : -1
  readonly property bool batteryCharging: batteryPresent && !UPower.onBattery
  readonly property string batteryIcon: {
    if (batteryCharging) return "󰂄"
    var icons = ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    return icons[Math.max(0, Math.min(10, Math.round(batteryLevel / 10)))]
  }
  property string hostName: ""

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  function forcePasswordFocus() {
    passwordInput.forceActiveFocus()
  }

  function clearPassword() {
    passwordTextEdited("")
  }

  // Waking a DPMS-blanked display can stall the compositor for seconds while
  // the monitor modesets, so the wake key's release arrives late and client-side
  // key repeat floods the field with that character. A held key has no business
  // typing a password; only holding Backspace/Delete to clear stays useful.
  function dropsAutoRepeat(key) {
    return key !== Qt.Key_Backspace && key !== Qt.Key_Delete
  }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return
    syncingPasswordText = true
    passwordInput.text = passwordText
    syncingPasswordText = false
  }

  // The field loses focus while a password is checked (it is disabled then),
  // and forcing focus onto it would not stick until the check ends.
  function restorePasswordFocus() {
    if (inputEnabled && passwordInput.enabled && !passwordInput.activeFocus) forcePasswordFocus()
  }

  onPasswordTextChanged: syncPasswordText()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  // A VT switch, which the NVIDIA driver forces around every suspend, takes the
  // keyboard away and Qt drops the field's focus with it. Nothing gives it back
  // when the keyboard returns, so typing went nowhere until the field was clicked.
  Window.onActiveFocusItemChanged: Qt.callLater(restorePasswordFocus)
  Component.onCompleted: {
    syncPasswordText()
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  // Measures the masked password at full size; passwordDotScale compares this
  // against the field width to decide how far the dots must shrink to fit.
  TextMetrics {
    id: dotMetrics
    font.family: Style.font.family
    font.pixelSize: root.passwordDotFontSize
    font.letterSpacing: root.passwordDotLetterSpacing
    text: "●".repeat(passwordInput.text.length)
  }

  Rectangle {
    anchors.fill: parent
    color: Commons.Color.background

    BackgroundMedia {
      id: wallpaper
      objectName: "lockWallpaper"
      anchors.fill: parent
      path: root.loadBackground ? (root.video ? root.videoPosterPath : root.backgroundPath) : ""
      version: root.backgroundVersion
      // Decode only once sized, at the lock's own size: an unsized first
      // request decoded the file at its native resolution, then again once
      // sized. That size is what the lock service keeps decoded ahead of the
      // lock, so the first frame has the wallpaper.
      cached: true
      constrainDecode: true
      decodeSize: Qt.size(width, height)
    }

    MultiEffect {
      anchors.fill: wallpaper
      source: wallpaper
      autoPaddingEnabled: false
      blurEnabled: root.loadBackground && wallpaper.ready
      blur: 1.0
      blurMax: 128
      blurMultiplier: 1.25
      contrast: -0.08
      // Moonfly look: the wallpaper's colour goes, so only its light and
      // shadow show through the wash (a warm wallpaper left a rust halo
      // behind the clock)
      saturation: -1.0
    }

    // Wash the blurred wallpaper toward the theme background so the lock
    // reads as moonfly's near-black canvas with only a hint of colour.
    Rectangle {
      anchors.fill: parent
      color: Commons.Color.background
      opacity: root.loadBackground && wallpaper.ready ? 0.72 : 1
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: { root.wakeRequested(); root.forcePasswordFocus() }
      onPositionChanged: root.wakeRequested()
    }

    SystemClock {
      id: clock
      precision: SystemClock.Minutes
    }

    FileView {
      path: "/etc/hostname"
      printErrors: false
      onLoaded: root.hostName = text().trim()
    }

    Column {
      id: centerColumn
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: -Math.round(parent.height * 0.04)
      spacing: 0

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
          textFormat: Text.PlainText
          text: Qt.formatDateTime(clock.date, "HH")
          color: root.clockColor
          font.family: Style.font.family
          font.pixelSize: root.clockFontSize
        }
        Text {
          textFormat: Text.PlainText
          text: ":"
          color: root.clockColor
          font.family: Style.font.family
          font.pixelSize: root.clockFontSize
        }
        Text {
          textFormat: Text.PlainText
          text: Qt.formatDateTime(clock.date, "mm")
          color: root.clockColor
          font.family: Style.font.family
          font.pixelSize: root.clockFontSize
        }
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        textFormat: Text.PlainText
        text: Qt.locale().toString(clock.date, "dddd, d MMMM")
        color: root.dateColor
        font.family: Style.font.family
        font.pixelSize: Math.round(Style.font.heading * 1.25)
      }

      Item { width: 1; height: Math.round(Style.font.heading * 3) }

      BorderSurface {
        id: inputField
        width: root.fieldWidth
        height: root.fieldHeight
        anchors.horizontalCenter: parent.horizontalCenter
        color: Commons.Color.lock.background
        borderSpec: root.inputBorderSpec
        radius: Style.cornerRadius
        clip: true

        TextInput {
          id: passwordInput
          anchors.fill: parent
          anchors.topMargin: inputField.borderTop
          // Reserve the fingerprint icon's width on both sides so the centered
          // dots stay symmetric and never slide under the icon as they grow.
          anchors.rightMargin: inputField.borderRight + 18 + root.fingerprintReserve
          anchors.bottomMargin: inputField.borderBottom
          anchors.leftMargin: inputField.borderLeft + 18 + root.fingerprintReserve
          verticalAlignment: TextInput.AlignVCenter
          horizontalAlignment: TextInput.AlignHCenter
          activeFocusOnPress: true
          clip: true
          enabled: root.inputEnabled && !root.authenticatingPassword
          readOnly: root.authenticatingPassword
          echoMode: TextInput.Password
          passwordCharacter: "\u25CF"
          passwordMaskDelay: 0
          color: Commons.Color.lock.text
          selectionColor: Commons.Color.lock.selection
          selectedTextColor: Commons.Color.lock.text
          font.family: Style.font.family
          font.pixelSize: text.length > 0 ? Math.max(1, Math.floor(root.passwordDotFontSize * root.passwordDotScale)) : root.fieldFontSize
          font.letterSpacing: text.length > 0 ? root.passwordDotLetterSpacing * root.passwordDotScale : 0
          cursorVisible: activeFocus && root.showPasswordCursor && text.length > 0
          cursorDelegate: Rectangle {
            width: 2
            color: Commons.Color.lock.text
            visible: passwordInput.cursorVisible
          }

          onTextChanged: {
            if (!root.syncingPasswordText) root.passwordTextEdited(text)
            if (text.length > 0) {
              root.wakeRequested()
            }
            if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
          }

          onAccepted: {
            var submitted = root.passwordText
            root.passwordTextEdited("")
            if (submitted.length > 0) root.submitPassword(submitted)
          }

          Keys.onPressed: function(event) {
            root.wakeRequested()
            if (event.isAutoRepeat && root.dropsAutoRepeat(event.key)) {
              event.accepted = true
              return
            }
            if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
              root.passwordTextEdited("")
              event.accepted = true
            }
          }
        }

        Text {
          textFormat: Text.PlainText
          anchors.fill: passwordInput
          text: root.authenticatingPassword ? Commons.I18n.t("lock.checking") : (root.failureMessage.length > 0 ? root.failureMessage : root.placeholderText)
          visible: passwordInput.text.length === 0
          color: root.authenticatingPassword ? Commons.Color.lock.text : (root.failureMessage.length > 0 ? Commons.Color.lock.textError : Commons.Color.lock.placeholder)
          font.family: Style.font.family
          font.pixelSize: root.fieldFontSize
          font.italic: !root.authenticatingPassword && root.failureMessage.length > 0
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideRight
        }

        // Fingerprint hint pinned inside the field's right edge when a sensor is
        // enrolled, so the user knows they can touch to unlock instead of typing.
        // Matches hyprlock, which draws its fingerprint icon in the same spot.
        // A reader the shell cannot reach crosses out rather than disappears, so
        // it stops inviting touches that can never unlock.
        Text {
          id: fingerprintIcon
          objectName: "fingerprintIndicator"
          textFormat: Text.PlainText
          anchors.right: parent.right
          anchors.rightMargin: inputField.borderRight + 18
          anchors.verticalCenter: parent.verticalCenter
          visible: root.fingerprintConfigured
          text: root.fingerprintUnavailable ? "󰺱" : "󰈷"
          color: root.fingerprintUnavailable ? Commons.Color.lock.textError : Commons.Color.lock.placeholder
          font.family: Style.font.family
          font.pixelSize: Math.round(root.fieldFontSize * 1.1)
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }
      }

      Item { width: 1; height: 18; visible: fingerprintNotice.visible }

      Text {
        id: fingerprintNotice
        objectName: "fingerprintUnavailableNotice"
        textFormat: Text.PlainText
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.fingerprintConfigured && root.fingerprintUnavailable
        text: Commons.I18n.t("lock.fingerprintUnavailable")
        color: Commons.Color.lock.textError
        font.family: Style.font.family
        font.pixelSize: Style.font.heading
        font.italic: true
        horizontalAlignment: Text.AlignHCenter
      }
    }

    // Neovim-style statusline along the bottom edge.
    Rectangle {
      id: statusline
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      height: root.statuslineHeight
      color: root.statuslineColor

      Row {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: 0

        Rectangle {
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          // Sized for the widest mode name, so the text after it never shifts.
          width: modeWidest.advanceWidth + Math.round(Style.font.body * 1.5)
          color: root.modeColor

          TextMetrics {
            id: modeWidest
            font: modeLabel.font
            text: "LOCKED"
          }

          Text {
            id: modeLabel
            anchors.centerIn: parent
            textFormat: Text.PlainText
            text: root.mode
            color: root.modeTextColor
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            font.bold: true
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          leftPadding: Math.round(Style.font.body * 0.9)
          textFormat: Text.PlainText
          text: "󰌾  " + Quickshell.env("USER") + (root.hostName ? "@" + root.hostName : "")
          color: Commons.Color.lock.text
          font.family: Style.font.family
          font.pixelSize: Style.font.body
        }
      }

      Row {
        anchors.right: parent.right
        anchors.rightMargin: Math.round(Style.font.body * 0.9)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Math.round(Style.font.body * 1.5)

        Text {
          visible: root.failedAttempts > 0
          textFormat: Text.PlainText
          text: "  " + root.failedAttempts
          color: Commons.Color.lock.textError
          font.family: Style.font.family
          font.pixelSize: Style.font.body
        }

        Text {
          visible: root.batteryLevel >= 0
          textFormat: Text.PlainText
          text: root.batteryIcon + " " + root.batteryLevel + "%"
          color: root.batteryLevel <= 15 && !root.batteryCharging ? Commons.Color.lock.textError : Commons.Color.lock.text
          font.family: Style.font.family
          font.pixelSize: Style.font.body
        }
      }
    }
  }
}

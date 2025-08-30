import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Ubuntu.Components 1.3 as UITK
import QtGraphicalEffects 1.0

UITK.ListItem {
    property bool passwordVisible: false
    property bool otpVisible: false
    property int otpRemaining: 0
    property string otpPassword

    height: units.gu(12)
    anchors.left: parent.left
    anchors.right: parent.right

    id: entireItem
    // leadingActions: UITK.ListItemActions {
    //     actions: [
    //         UITK.Action {
    //             visible: url
    //             // iconSource: "../../assets/web.png"
    //             onTriggered: {
    //                 if (url.indexOf('//') === -1) {
    //                     Qt.openUrlExternally('http://' + url)
    //                     return
    //                 }
    //                 Qt.openUrlExternally(url)
    //             }
    //         }
    //     ]
    // }

    //override the trailing action panels defaul colors
    //use #808080 for icon color, this is the default keycolor of `Icon` and will then be changed to the themed color
    UITK.StyleHints {
        trailingPanelColor: theme.palette.normal.foreground
        trailingForegroundColor: theme.palette.normal.foregroundText
    }

    trailingActions: UITK.ListItemActions {
        actions: [

            UITK.Action {
                visible: username
                iconSource: "../../assets/user.svg"
                onTriggered: {
                    UITK.Clipboard.push(username)
                    toast.show("Username copied to clipboard")
                }
            },
            UITK.Action {
                visible: password
                iconSource: "../../assets/key.svg"
                onTriggered: {
                    UITK.Clipboard.push(password)
                    toast.show("Password copied to clipboard")
                }
            },
            UITK.Action {
                visible: url
                iconName: "external-link"
                onTriggered: {
                    if (url.indexOf('//') === -1) {
                        Qt.openUrlExternally('http://' + url)
                        return
                    }

                    Qt.openUrlExternally(url)
                }
            },
            UITK.Action {
                visible: has_totp
                iconSource: "../../assets/2fa.svg"
                iconName: "external-link"
                onTriggered: {
                    python.call('kp.get_totp', [uuid], function (result) {
                        UITK.Clipboard.push(result.code)
                        toast.show("Token '" + result.code + "' copied. Valid for "
                                   + result.valid_for + "s")
                    })
                }
            }
        ]
    }
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
    }

    Row {
        anchors.leftMargin: units.gu(2)
        anchors.rightMargin: units.gu(2)
        anchors.topMargin: units.gu(1)
        anchors.bottomMargin: units.gu(1)
        anchors.fill: parent

        spacing: units.gu(1)
        Image {
            id: entryImg
            visible: icon_path.length > 0
            fillMode: Image.PreserveAspectFit
            source: 'file://' + icon_path
            width: units.gu(6)
            height: parent.height
            y: parent.height / 2 - height / 2
        }

        // Rounded square with the first letter of the title
        Rectangle {
            id: letterSquare
            visible: icon_path.length == 0
            width: units.gu(6)
            height: units.gu(6)
            radius: units.gu(1) // Rounded corners
            color: getColorFromTitle(title) // Color based on the title
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: title.charAt(0).toUpperCase() // First letter, uppercase
                anchors.centerIn: parent
                font.pointSize: units.gu(2.5)
                color: "white" // Text color for contrast
            }
        }

        Column {
            id: detailsColumn
            width: parent.width - parent.spacing - units.gu(7)
            anchors.verticalCenter: parent.verticalCenter // Center the Column vertically
            spacing: units.gu(0.5) // Spacing between Text elements inside Column

            Text {
                width: parent.width
                visible: (!otpVisible) && (!passwordVisible) 
                elide: Text.ElideRight
                text: title
                font.pointSize: units.gu(3)
                color: theme.palette.normal.foregroundText
            }

            Text {
                width: parent.width
                visible: (!otpVisible) && (!passwordVisible) 
                elide: Text.ElideRight
                color: theme.palette.normal.backgroundTertiaryText
                text: username
            }

            Text {
                width: parent.width
                visible: (url.length > 0) && (!otpVisible) && (!passwordVisible) 
                elide: Text.ElideRight
                color: theme.palette.normal.backgroundTertiaryText
                text: url
            }

            Text {
		        visible: (password.length > 0) && (passwordVisible) 
                //text: (passwordVisible ? password : '••••••••' )
                text: password
                font.pointSize: units.gu(3)
                color: theme.palette.normal.foregroundText
            }

            Text {
                visible: has_totp && otpVisible
                //text: i18n.ctr("otp entry field","OTP : ") + (otpVisible ? (otpPassword + ' - ' + otpRemaining + 's' ) : '••••••••' )
                text: otpPassword + ' - ' + otpRemaining + 's'
                font.pointSize: units.gu(3)
                color: theme.palette.normal.foregroundText
            }
        }
    }

    MouseArea {
        x: parent.x
        width: entryImg.width + detailsColumn.width
        height: parent.height
        onClicked: {
            if (!settings.tapToReveal) {
                return
            }

            if(has_totp) {
                python.call('kp.get_totp', [uuid], function (result) {
                otpPassword = result.code
                otpRemaining = result.valid_for
                otpVisible = true
                timer_otp.restart()
                        })
            }

            if(password.length) {
                passwordVisible = true
                timer.interval = settings.autoHideInterval * 1000
                timer.restart()
            } 

            if((!has_totp)&&(!password.length)) {
                toast.show(i18n.ctr("no password to reveal","No password to reveal"))
            }
        }
    }
    Timer {
        id: timer
        repeat: false
        interval: 1500
        onTriggered: passwordVisible = false
    }
    Timer {
        id: timer_otp
        repeat: false
        interval: 1000
        onTriggered: {
		if(otpRemaining == 1) {
			otpVisible = false
			otpRemaining = 0
		} else {
			otpRemaining = otpRemaining - 1
			otpVisible = true
			timer_otp.restart()
		}	
	}
    }


    // Function to generate a color from the title (simple hash-based approach)
    function getColorFromTitle(title) {
        // Simple hash function to generate a color from the title
        var hash = 0;
        for (var i = 0; i < title.length; i++) {
            hash = title.charCodeAt(i) + ((hash << 5) - hash);
        }
        // Convert hash to a color
        var color = Qt.hsva(
            Math.abs(hash) % 360 / 360, // Hue (0-1)
            0.7, // Saturation
            0.7,  // Value
            1.0
        );
        console.log("OUOU");
        console.log(color);
        return color;
    }

}
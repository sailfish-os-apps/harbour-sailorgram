import QtQuick 2.1
import Sailfish.Silica 1.0
import harbour.sailorgram.LibQTelegram 1.0
import "../../components/message/input"
import "../../components/dialog"
import "../../items"
import "../../model"
import "../peer"

SilicaListView
{
    readonly property alias dialogInputPanel: messageslist.headerItem
    property bool selectionMode: false
    property bool positionPending: false
    property var selectedMessages: null

    function getSelectionList() {
        var selectionlist = [ ];

        for(var selindex in selectedMessages) {
            if(!selectedMessages.hasOwnProperty(selindex))
                continue;

            selectionlist.push(messagesmodel.get(selindex));
        }

        return selectionlist;
    }

    property int lastCount

    Component.onCompleted: {
        lastCount = count
    }

    onCountChanged: {
        if (lastCount == 0 && model.newMessageIndex >= 0 && model.newMessageIndex < count) {
            positionViewAtIndex(model.newMessageIndex, ListView.Center);
        }
        lastCount = count
    }

    Connections {
        target: model
        onNewMessageIndexChanged: {
            if (model.newMessageIndex >= 0 && model.newMessageIndex < count) {
                positionViewAtIndex(model.newMessageIndex, ListView.Center);
            }
        }
    }

    Connections
    {
        target: dialogpage.context.positionSource

        onPositionChanged: {
            if(!positionPending)
                return;

            messagesmodel.sendLocation(dialogpage.context.positionSource.position.coordinate.latitude,
                                       dialogpage.context.positionSource.position.coordinate.longitude);

            positionPending = false;
        }
    }

    id: messageslist
    cacheBuffer: Screen.height * 2
    verticalLayoutDirection: ListView.BottomToTop
    currentIndex: -1

    onSelectionModeChanged: {
        if(selectionMode) {
            selectedMessages = new Object;
            return;
        }

        delete selectedMessages;
    }

    header: DialogInputPanel {
        width: messageslist.width
    }

    delegate: Column {
        width: ListView.view.width
        spacing: Theme.paddingSmall

        NewMessage { id: newmessage; visible: model.isMessageNew }

        Row {
            width: parent.width

            GlassItem
            {
                id: selindicator
                anchors.verticalCenter: parent.verticalCenter
                visible: selectionMode
                dimmed: !messagemodelitem.selected
            }

            Item {
                id: picontainer
                anchors.top: parent.top
                x: Theme.paddingSmall
                height: peerimage.height

                width: {
                    if(messagesmodel.isChat && !model.isMessageOut && !model.isMessageService)
                        return peerimage.size;

                    return 0;
                }

                PeerImage {
                    id: peerimage
                    size: Theme.iconSizeSmallPlus
                    peer: model.needsPeerImage ? model.item : null
                    visible: model.needsPeerImage && !model.isMessageOut && messagesmodel.isChat
                }
            }

            MessageModelItem {
                id: messagemodelitem
                maxWidth: width * 0.8

                width: {
                    var w = parent.width - picontainer.width;

                    if(selindicator.visible)
                        w -= selindicator.width;

                    return w;
                }

                onReplyRequested: {
                    dialogInputPanel.prepareReply(model);
                    messageslist.positionViewAtBeginning();
                }

                onEditRequested: {
                    dialogInputPanel.prepareEdit(model);
                    messageslist.positionViewAtBeginning();
                }
            }
        }
    }

    VerticalScrollDecorator { flickable: messageslist }
}

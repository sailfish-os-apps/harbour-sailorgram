import QtQuick 2.1
import Sailfish.Silica 1.0
import harbour.sailorgram.LibQTelegram 1.0
import "../../components/message/input"
import "../../components/dialog"
import "../../items"
import "../../model"

SilicaListView
{
    property Message selectedMessage: null
    property string selectedMessageFrom
    property string selectedMessageText
    property bool replyMode: false
    property bool editMode: false
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

    function prepareActions(model) {
        messageslist.selectedMessage = model.item;
        messageslist.selectedMessageFrom = model.messageFrom;
        messageslist.selectedMessageText = model.messageText;
    }

    function activateInput() {
        headerItem.activateInput();
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

    Component.onCompleted: messageslist.positionViewAtIndex(model.newMessageIndex, ListView.Center);

    onSelectionModeChanged: {
        if(selectionMode) {
            selectedMessages = new Object;
            return;
        }

        delete selectedMessages;
    }

    header: Column {
        function activateInput(text) {
            if(text)
                messagetextinput.text = text;

            messagetextinput.focusTextArea();
        }

        function cancelActions() {
            replyMode = editMode = false;
            selectedMessageFrom = selectedMessageText = "";
            selectedMessage = null;
        }

        id: messagelistheader
        width: messageslist.width

        height: {
            if(selectionMode)
                return 0;

            if(dialognotificationswitch.visible)
                return dialognotificationswitch.height;

            return messagereplyinput.height + messagetextinput.height + Theme.paddingSmall;
        }

        Item { width: parent.width; height: Theme.paddingSmall }

        DialogNotificationSwitch
        {
            id: dialognotificationswitch
            width: parent.width
            visible: messagesmodel.isBroadcast && !messagesmodel.isWritable
        }

        MessageReplyInput {
            id: messagereplyinput
            replyMessage: replyMode ? selectedMessage : null
            replyFrom: replyMode ? selectedMessageFrom : ""
            replyText: replyMode ? selectedMessageText : ""
            width: parent.width
            onReplyCancelled: messagelistheader.cancelActions()
        }

        MessageTextInput {
            id: messagetextinput
            width: parent.width
            onShareMedia: dialogmediapanel.expanded ? dialogmediapanel.hide() : dialogmediapanel.show()

            onSendMessage: {
                if(replyMode)
                    messagesmodel.replyMessage(message, selectedMessage)
                else if(editMode)
                    messagesmodel.editMessage(message, selectedMessage);
                else
                    messagesmodel.sendMessage(message);

                messagelistheader.cancelActions();
            }
        }
    }

    delegate: Column {
        width: parent.width
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
                    backgroundColor: Theme.secondaryHighlightColor
                    foregroundColor: Theme.primaryColor
                    fontPixelSize: Theme.fontSizeExtraSmall
                }
            }

            MessageModelItem {
                id: messagemodelitem
                maxWidth: width * 0.8

                width: {
                    var w = parent.width - picontainer.width - Theme.paddingSmall;

                    if(selindicator.visible)
                        w -= selindicator.width;

                    return w;
                }

                onReplyRequested: {
                    prepareActions(model);

                    editMode = false;
                    replyMode = true;

                    headerItem.activateInput();
                }

                onEditRequested: {
                    prepareActions(model);

                    editMode = true;
                    replyMode = false;

                    headerItem.activateInput(selectedMessageText);
                }
            }
        }
    }

    VerticalScrollDecorator { flickable: messageslist }
}

/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.sailorgram.TelegramQml 1.0
import "../../items"

Page
{
    property Telegram telegram

    id: conversationspage
    allowedOrientations: defaultAllowedOrientations

    SilicaListView
    {
        PullDownMenu
        {
            MenuItem {
                text: qsTr("Contacts")
                onClicked: pageStack.push(Qt.resolvedUrl("../users/UsersPage.qml"), { "telegram": telegram })
            }
        }

        ViewPlaceholder
        {
            enabled: lvchats.count <= 0
            text: qsTr("No Chats\n\nPick a contact by selecting \"Contacts\" from the Pull Down Menu")
        }

        id: lvchats
        spacing: Theme.paddingMedium
        anchors.fill: parent

        header: PageHeader {
            title: qsTr("Chats")
        }

        model: DialogsModel {
            telegram: conversationspage.telegram
        }

        delegate: ListItem {
            id: dialogitem
            contentWidth: parent.width
            contentHeight: Theme.itemSizeSmall
            onClicked: pageStack.push(Qt.resolvedUrl("ConversationPage.qml"), {"telegram": conversationspage.telegram, "dialog": item })

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Delete History")

                    onClicked: {
                        dialogitem.remorseAction(qsTr("Deleting History"), function() {
                            telegram.messagesDeleteHistory(item.peer.userId);
                        });
                    }
                }
            }

            ConversationItem {
                anchors.fill: parent
                dialog: item
            }
        }
    }
}

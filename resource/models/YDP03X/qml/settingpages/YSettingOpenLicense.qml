import QtQuick 2.12
import com.youdao.pen 1.0
import "../components"
import BaseQml 1.0
import "../i18n"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===YSettingOpenLicense.qml"

    property string tips:  "<center> <b>Legal Disclaimer and Notices </b> </center><br>
The Service which is provided by YOUDAO products may include open source software (“OSS”).
Open source projects are made available and contributed to under licenses that include terms that,
for the protection of contributors, make clear that the projects are offered “as-is”. To the extent
 so provided by the license that governs each OSS (“OSS License“), the applicable OSS is subject to
its respective OSS License. You agree to comply with all such licenses and other notices. If you do
not agree to such terms, you may not install, download, distribute or otherwise use the open source
software.<br><br>
YOUDAO does not make any representation or warranty with respect to any OSS or free software
that may be included in or accompany the Service. YOUDAO HEREBY DISCLAIMS ANY AND ALL LIABILITY TO
DEMAND PARTNER OR ANY THIRD PARTY RELATED TO ANY SUCH SOFTWARE THAT MAY BE INCLUDED IN OR ACCOMPANY
THE SERVICE.<br><br>
With respect to the open source software listed in this document, you can receive a copy
of the source code referring to Qt at<u> https://www.qt.io/. </u> <b>If you have any questions about which you
are entitled under the applicable open source license(s), please contact us youdaocidianbi@163.com <br><br>
Qt is available under the GNU Lesser General Public License version 3.<br>
The Qt Toolkit is Copyright (C) 2018 The Qt Company Ltd. and other contributors.<br>
Contact: <u>https://www.qt.io/licensing/. </u><br>
Reference:</b>
<center> <b>     GNU LESSER GENERAL PUBLIC LICENSE    </b> </center>
<center>Version 3, 29 June 2007</center>
Copyright © 2007 Free Software Foundation, Inc. &lt;https://fsf.org/&gt;<br>
Everyone is permitted to copy and distribute verbatim copies of this license document, but changing it is not allowed.<br><br>
This version of the GNU Lesser General Public License incorporates the terms and conditions of version 3 of the GNU General
Public License, supplemented by the additional permissions listed below.<br><br>
<b>      0. Additional Definitions.       </b><br><br>
As used herein, “this License” refers to version 3 of the GNU Lesser General Public License,
 and the “GNU GPL” refers to version 3 of the GNU General Public License.<br>
“The Library” refers to a covered work governed by this License, other than an Application or a
Combined Work as defined below.<br><br>
An “Application” is any work that makes use of an interface provided by the Library, but which is
not otherwise based on the Library. Defining a subclass of a class defined by the Library is deemed a
mode of using an interface provided by the Library.<br><br>
A “Combined Work” is a work produced by combining or linking an Application with the Library. The
particular version of the Library with which the Combined Work was made is also called the “Linked Version”.<br><br>
The “Minimal Corresponding Source” for a Combined Work means the Corresponding Source for the Combined Work,
excluding any source code for portions of the Combined Work that, considered in isolation, are based on the
Application, and not on the Linked Version.<br><br>
The “Corresponding Application Code” for a Combined Work means the object code and/or source code for the
Application, including any data and utility programs needed for reproducing the Combined Work from the Application,
but excluding the System Libraries of the Combined Work.<br><br>
<b> 1. Exception to Section 3 of the GNU GPL. </b><br><br>
You may convey a covered work under sections 3 and 4 of this License without being bound by section 3 of the GNU GPL.<br><br>
<b> 2. Conveying Modified Versions. </b><br><br>
If you modify a copy of the Library, and, in your modifications, a facility refers to a function or data to be supplied by
an Application that uses the facility (other than as an argument passed when the facility is invoked), then you may convey
a copy of the modified version:<br><br>
&#9632;	a) under this License, provided that you make a good faith effort to ensure that, in the event an Application does
not supply the function or data, the facility still operates, and performs whatever part of its purpose remains meaningful, or<br>
&#9632;	b) under the GNU GPL, with none of the additional permissions of this License applicable to that copy.<br><br>
<b> 3. Object Code Incorporating Material from Library Header Files.</b><br><br>
The object code form of an Application may incorporate material from a header file that is part of the Library.
 You may convey such object code under terms of your choice, provided that, if the incorporated material is not
 limited to numerical parameters, data structure layouts and accessors, or small macros, inline functions and
templates (ten or fewer lines in length), you do both of the following:<br><br>
&#9632;	a) Give prominent notice with each copy of the object code that the Library is used in it and that the
Library and its use are covered by this License.<br>
&#9632;	b) Accompany the object code with a copy of the GNU GPL and this license document.<br><br>
<b> 4. Combined Works. </b><br><br>
You may convey a Combined Work under terms of your choice that, taken together, effectively do not restrict
 modification of the portions of the Library contained in the Combined Work and reverse engineering for
 debugging such modifications, if you also do each of the following:<br><br>
&#9632;	a) Give prominent notice with each copy of the Combined Work that the Library is used in it and that
 the Library and its use are covered by this License.<br>
&#9632;	b) Accompany the Combined Work with a copy of the GNU GPL and this license document.<br>
&#9632;	c) For a Combined Work that displays copyright notices during execution, include the copyright
notice for the Library among these notices, as well as a reference directing the user to the copies
 of the GNU GPL and this license document.<br>
&#9632;	d) Do one of the following:<br>
&#9632;	0) Convey the Minimal Corresponding Source under the terms of this License, and the Corresponding
 Application Code in a form suitable for, and under terms that permit, the user to recombine or relink
 the Application with a modified version of the Linked Version to produce a modified Combined Work,
in the manner specified by section 6 of the GNU GPL for conveying Corresponding Source.</p> <br>
&#9632;	1) Use a suitable shared library mechanism for linking with the Library. A suitable mechanism is
 one that (a) uses at run time a copy of the Library already present on the user's computer system,
and (b) will operate properly with a modified version of the Library that is interface-compatible
with the Linked Version.</p> <br>
&#9632;	e) Provide Installation Information, but only if you would otherwise be required to provide such
information under section 6 of the GNU GPL, and only to the extent that such information is necessary
to install and execute a modified version of the Combined Work produced by recombining or relinking
the Application with a modified version of the Linked Version. (If you use option 4d0, the Installation
 Information must accompany the Minimal Corresponding Source and Corresponding Application Code. If
you use option 4d1, you must provide the Installation Information in the manner specified by section 6
of the GNU GPL for conveying Corresponding Source.)<br><br>
<b> 5. Combined Libraries. </b><br><br>
You may place library facilities that are a work based on the Library side by side in a single library
 together with other library facilities that are not Applications and are not covered by this License,
 and convey such a combined library under terms of your choice, if you do both of the following:<br><br>
&#9632;	a) Accompany the combined library with a copy of the same work based on the Library, uncombined
with any other library facilities, conveyed under the terms of this License.<br>
&#9632;	b) Give prominent notice with the combined library that part of it is a work based on the Library,
 and explaining where to find the accompanying uncombined form of the same work.<br><br>
<b> 6. Revised Versions of the GNU Lesser General Public License. </b><br><br>
The Free Software Foundation may publish revised and/or new versions of the GNU Lesser General Public
 License from time to time. Such new versions will be similar in spirit to the present version, but
may differ in detail to address new problems or concerns.<br><br>
Each version is given a distinguishing version number. If the Library as you received it specifies
that a certain numbered version of the GNU Lesser General Public License “or any later version”
applies to it, you have the option of following the terms and conditions either of that published
version or of any later version published by the Free Software Foundation. If the Library as you
received it does not specify a version number of the GNU Lesser General Public License, you may
 choose any version of the GNU Lesser General Public License ever published by the Free Software Foundation.<br><br>
If the Library as you received it specifies that a proxy can decide whether future versions of the
 GNU Lesser General Public License shall apply, that proxy's public statement of acceptance of any version is
permanent authorization for you to choose that version for the Library.<br>"

    property var popcurrentShowPage: null

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_update_content_col.height
        boundsBehavior: Flickable.StopAtBounds
        Column {
            id: id_update_content_col

            YSettingItemTitle {
                id: id_title_container
                title: YTranslateText.opensourcelicense
            }

            YText {
                color: YColors.grayText
                font.pixelSize: 28
                font.family: fontManager.fontFamilyZhCn
                width: 694
                textFormat: Text.RichText
                wrapMode: YTextBase.Wrap
                text: tips
                lineHeightMode: Text.FixedHeight
                lineHeight: 36
                verticalAlignment: YText.AlignVCenter
            }

            //修改软件
            YSettingAboutClickableItem {
                title: YTranslateText.modifysoftware
                value: ""
                width: 694
                imageName: "settings/info_more_arrow"
                onClicked: {
                    settingModifySoftware.visible = true
                }
            }

        }

    }
    YSettingModifySoftware
    {
       id:settingModifySoftware
       anchors.fill: parent
       visible :false;
       onCallback:
       {
           settingModifySoftware.visible = false;
       }
    }

}

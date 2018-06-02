# navigatAR

Finding your way through buildings and campuses through the power of augmented reality

> navigatAR is an iOS app that shows you where to go in an accessible, user-friendly way. No more asking for directions or searching for a map, you can use a simple app instead. navigatAR leverages the power of augmented reality to provide indoor directions to areas, rooms, and even events, displayed by arrows that show you where to go in real-time.

**WARNING: This was the result of a 6-week hackathon. This is not polished nor fully functional but rather just a demo—use at your discretion.**

# Technologies

We created an native Swift iOS app that used ARKit for augmented reality and Indoor Atlas for indoor positioning. Throughout the development process we used Slack for communication and GitHub projects to keep track of what features were in progress.

# Setup

## Installation

First, install Xcode, navigate to the `/navigatAR` directory in the root of the project, then run:

```
$ pod install
```

## Config

navigatAR uses Indoor Atlas for navigation. [Create a free account and API credentials here.](http://www.indooratlas.com/) Configure the app to use these credentials by copying [`/navigatAR/navigatAR/config.example.plist`](https://github.com/michaelgira23/navigatAR/blob/master/navigatAR/navigatAR/config.example.plist) into another file `config.plist` in the same directory. This should be in the `.gitignore`, so credentials won't be committed.

This should be your `/navigatAR/navigatAR/config.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>IAAPIKeyId</key>
	<string>YOUR_INDOOR_ATLAS_API_KEY</string>
	<key>IAAPIKeySecret</key>
	<string>YOUR_INDOOR_ATLAS_API_KEY</string>
</dict>
</plist>
```

## Indoor Atlas

After putting Indoor Atlas API credentials into the config, you must map out your building(s) in the Indoor Atlas web interface. Upload floor plans, then use your Android device to walk around and map out Wi-Fi signals and electromagnetic waves. Once uploaded online, these changes should give more accurate location readings to navigatAR.

# Usage

## Creating a new Building

Navigate to the "User" page, register/login, then click "New Building." Enter the venue's name and how many floors it has.

## Mapping out Points of Interest

Click the newly created building to bring up management options specific to the selected venue. "Manage Nodes" will show a list of "Nodes" associated with the building. A node is simply a point of interest that will show on the map. This can be a room, bathroom, etc. Add a "Pathway" node to map out hallway corners, path intersections, etc. that mark navigable pathways for the user that don't represent a point of interest.

## Connecting Nodes

After mapping the locations of points of interest and pathways, connect them via the "Manage Nodes graphic interface" button. This brings up a map of the current building populates with the nodes. Tap one node then another to create a connection signified by a line. Tap existing lines to delete that node connection.

## Managing Searchable Tags

The next option for each building is managing "tags." A tag is a customizable property that can be set for nodes. Examples include "Room Number" or "Teacher Name" for school classrooms.

## Create a Custom Event

When there is a temporary event taking place at the venue, admins can create an event via the "New Event" button. This is a temporary connection to nodes for a predefined duration. An event will be searchable just like any other node, but will show a list of nodes the user can navigate to.

## Main Interface Demo

![Demo of Search and Pathfinding](https://i.imgur.com/khWxOed.gif)

# Hackathon

The MICDS team won third place out of 20 schools winning $2,500 for our school!

## Team

navigatAR was made with the hard work of:

- Jack Cai (2019)
- Tanay Chandak (2020)
- Nick Clifford (2020)
- Alexander Donovan (2018)
- Michael Gira (2019)
- Alex Migala (2020)
- Jack Petersen (2020)
- Sophia Puertas (2019)
- Andrew Zhao (2019)

Special thanks for the guidance of our faculty sponsors Mrs. Purdy and Mr. Borja!

Last but certainly not least, many thanks to our WWT mentors Satya Gudivada and Lisa Rains!

![MICDS Team at WWT Hackathon 2018](https://drive.google.com/uc?export=view&id=1yogw1DR_dLDsXnrOesT2jTUWSJU8Gw2s)

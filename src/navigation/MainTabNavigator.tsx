import { Ionicons } from '@expo/vector-icons';
import * as React from 'react';
import { Platform } from 'react-native';
import { TabBarBottom, TabNavigator } from 'react-navigation';

import Colors from '../constants/Colors';

import { HomeScreen } from '../screens/HomeScreen';
import { SettingsScreen } from '../screens/SettingsScreen';

const navbarOptions = {
	// tabBarComponent: TabBarBottom,
	// tabBarPosition: 'bottom',
	// animationEnabled: false,
	// swipeEnabled: false
};

export default TabNavigator(
	{
		Home: {
			screen: HomeScreen,
			navigationOptions: {
				...navbarOptions,
				tabBarLabel: 'Home',
				tabBarIcon: ({ focused }) => getIcon({
					ios: `ios-information-circle${focused ? '' : '-outline'}`,
					android: 'md-information-circle'
				}, focused)
			}
		},
		Settings: {
			screen: SettingsScreen,
			navigationOptions: {
				...navbarOptions,
				tabBarLabel: 'Settings',
				tabBarIcon: ({ focused }) => getIcon({
					ios: `ios-options${focused ? '' : '-outline'}`,
					android: 'md-options'
				}, focused)
			}
		}
	}
);

function getIcon(names: { ios: string; android: string }, focused) {
	return (
		<Ionicons
			name={Platform.OS === 'ios' ? names.ios : names.android}
			size={28}
			style={{ marginBottom: -3 }}
			color={focused ? Colors.tabIconSelected : Colors.tabIconDefault}
		/>
	);
}

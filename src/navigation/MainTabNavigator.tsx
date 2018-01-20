import { Ionicons } from '@expo/vector-icons';
import * as React from 'react';
import { Platform } from 'react-native';
import { TabBarBottom, TabNavigator } from 'react-navigation';

import Colors from '../constants/Colors';

import { HomeScreen } from '../screens/HomeScreen';
import { SettingsScreen } from '../screens/SettingsScreen';

export default TabNavigator(
	{
		Home: {
			screen: HomeScreen
		},
		Settings: {
			screen: SettingsScreen
		}
	},
	({
		navigationOptions: ({ navigation }) => ({
			tabBarIcon: ({ focused }) => {
				const { routeName } = navigation.state;
				let iconName;
				switch (routeName) {
					case 'Home':
						iconName =
							Platform.OS === 'ios'
								? `ios-information-circle${focused ? '' : '-outline'}`
								: 'md-information-circle';
						break;
					case 'Links':
						iconName = Platform.OS === 'ios' ? `ios-link${focused ? '' : '-outline'}` : 'md-link';
						break;
					case 'Settings':
						iconName =
							Platform.OS === 'ios' ? `ios-options${focused ? '' : '-outline'}` : 'md-options';
				}
				return (
					<Ionicons
						name={iconName}
						size={28}
						style={{ marginBottom: -3 }}
						color={focused ? Colors.tabIconSelected : Colors.tabIconDefault}
					/>
				);
			}
		}),
		tabBarComponent: TabBarBottom,
		tabBarPosition: 'bottom',
		animationEnabled: false,
		swipeEnabled: false
	} as any)
);

import { Notifications } from 'expo';
import * as React from 'react';
import { StackNavigator } from 'react-navigation';

import MainTabNavigator from './MainTabNavigator';

const RootStackNavigator = StackNavigator(
	{
		Main: {
			screen: MainTabNavigator
		}
	},
	({
		navigationOptions: () => ({
			headerTitleStyle: {
				fontWeight: 'normal'
			}
		})
	} as any)
);

export default class RootNavigator extends React.Component {
	render() {
		return <RootStackNavigator />;
	}
}

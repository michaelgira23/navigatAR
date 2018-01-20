import * as React from 'react';
import { Platform, StyleSheet, Text } from 'react-native';

export class HomeScreen extends React.Component {
	static navigationOptions = {
		title: 'Home'
	};

	render() {
		return (
			<Text>Home Screen</Text>
		);
	}
}

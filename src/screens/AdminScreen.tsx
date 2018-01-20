import { Constants, Location, Permissions } from 'expo';
import * as React from 'react';
import { Button, Platform, StyleSheet, Text, View } from 'react-native';

export class AdminScreen extends React.Component {
	static navigationOptions = {
		title: 'Admin Panel'
	};

	state = {
		location: null,
		errorMessage: null
	};

	_getLocationAsync = async () => {
		const { status } = await Permissions.askAsync(Permissions.LOCATION as Permissions.PermissionType);
		if (status !== 'granted') {
			this.setState({
				errorMessage: 'Permission to access location was denied'
			});
		}

		this.setState({ location: 'Wating...' });
		const location = await Location.getCurrentPositionAsync({});
		this.setState({ location: JSON.stringify(location) });
	}

	render() {
		return (
			<View>
				<Button
					onPress={this._getLocationAsync}
					title="Get Location"
				/>
				<Text>{this.state.errorMessage ? this.state.errorMessage : this.state.location}</Text>
			</View>
		);
	}
}

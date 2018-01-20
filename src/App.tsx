import * as React from 'react';
// import Icon from 'react-native-vector-icons/MaterialIcons'

import { Platform, StatusBar, StyleSheet, Text, View } from 'react-native';
import { AppLoading, Asset, Font } from 'expo';
import { Ionicons } from '@expo/vector-icons';
import RootNavigation from './navigation/RootNavigation';

export default class App extends React.Component<any, any> {

	state = {
		isLoadingComplete: false
	};

	render() {
		if (!this.state.isLoadingComplete && !this.props.skipLoadingScreen) {
			return (
				<AppLoading
					startAsync={this._loadResourcesAsync}
					onError={this._handleLoadingError}
					onFinish={this._handleFinishLoading}
				/>
			);
		} else {
			return (
				<View style={styles.container}>
					{Platform.OS === 'ios' && <StatusBar barStyle="default" />}
					{Platform.OS === 'android' && <View style={styles.statusBarUnderlay} />}
					<RootNavigation />
				</View>
			);
		}
		// return (
		// 	<View style={styles.container}>
		// 		<Text>Open up App.ts to start working on your app!!!</Text>
		// 		<Text>Changes you make will automatically reload.</Text>
		// 		<Text>Shake your phone to open the developer menu.</Text>
		// 	</View>
		// );
	}

	_loadResourcesAsync = async () => {
		return Promise.all([
			// Asset.loadAsync([
			// 	require('./assets/images/robot-dev.png'),
			// 	require('./assets/images/robot-prod.png'),
			// ]),
			Font.loadAsync({
				// This is the font that we are using for our tab bar
				...Ionicons.font,
				// We include SpaceMono because we use it in HomeScreen.js. Feel free
				// to remove this if you are not using it in your app
				'space-mono': require('./assets/fonts/SpaceMono-Regular.ttf')
			})
		]);
	}

	_handleLoadingError = error => {
		// In this case, you might want to report the error to your error
		// reporting service, for example Sentry
		console.warn(error);
	}

	_handleFinishLoading = () => {
		this.setState({ isLoadingComplete: true });
	}
}

const styles = StyleSheet.create({
	container: {
		flex: 1,
		backgroundColor: '#fff'
	},
	statusBarUnderlay: {
		height: 24,
		backgroundColor: 'rgba(0,0,0,0.2)'
	}
});

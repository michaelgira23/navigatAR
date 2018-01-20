import * as React from 'react';
import { Platform, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import firebase from '../constants/FirebaseConfig';
import Layout from '../constants/Layout';

export class SettingsScreen extends React.Component {

	static navigationOptions = {
		title: 'Settings'
	};

	state = {
		loading: false,
		text: ''
	};

	componentWillMount() {
		let initialLoad = true;
		this.setState({ loading: true });
		firebase.firestore().collection('nodes').where('location', '==', 'MICDS').onSnapshot(querySnapshot => {
			let newText = '';
			querySnapshot.forEach(doc => {
					newText += doc.id + ' => ' + JSON.stringify(doc.data());
			});

			this.setState({ text: newText });

			if (initialLoad) {
				initialLoad = false;
				this.setState({ loading: false });
			}
		});
	}

	render() {
		return (
			<View style={styles.container}>
				<Text style={styles.title}>
					Store some value in Firebase!
				</Text>

				<ScrollView>
					<Text>
						{this.state.text}
					</Text>
				</ScrollView>
			</View>
		);
	}
}

const styles = StyleSheet.create({
	container: {
		height: '100%',
		// flex: 1,
		backgroundColor: '#fff',
		alignItems: 'center',
		justifyContent: 'center'
	},
	title: {
		fontSize: 20
	},
	textInput: {
		width: Layout.window.width - 30,
		marginHorizontal: 15,
		padding: 5,
		borderRadius: 2,
		borderWidth: 1,
		borderColor: '#eee',
		marginVertical: 15,
		height: 50,
		fontSize: 16
	},
	loadingOverlay: {
		backgroundColor: 'rgba(0,0,0,0.4)',
		alignItems: 'center',
		justifyContent: 'center'
	}
});

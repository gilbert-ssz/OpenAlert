import { useState, useEffect } from "react";
import { View, Text, TouchableOpacity, SafeAreaView, StatusBar, Platform, StyleSheet } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import useDoorSensor from "./hooks/useDoorSensor";
import HomeScreen from "./screens/HomeScreen";
import ActivityScreen from "./screens/ActivityScreen";
import { COLORS as C } from "./config";

const TABS = [
  { name: "Home", icon: "home" },
  { name: "Activity", icon: "pulse" },
  { name: "Devices", icon: "hardware-chip-outline" },
  { name: "Settings", icon: "settings-outline" },
];

export default function App() {
  const [tab, setTab] = useState("Home");
  const sensor = useDoorSensor(); // ang data gikan sa sensor naa dinhi

  // Kung naay alert, ablihi dayon ang Activity screen
  useEffect(() => { if (sensor.triggered) setTab("Activity"); }, [sensor.triggered]);

  return (
    <SafeAreaView style={s.app}>
      <StatusBar barStyle="light-content" />
      <View style={{ flex: 1 }}>
        {tab === "Home" && <HomeScreen sensor={sensor} goTo={setTab} />}
        {tab === "Activity" && <ActivityScreen sensor={sensor} />}
        {(tab === "Devices" || tab === "Settings") && (
          <View style={s.center}><Text style={{ color: C.muted }}>{tab} — coming soon</Text></View>
        )}
      </View>

      <View style={s.tabBar}>
        {TABS.map((t) => (
          <TouchableOpacity key={t.name} style={s.tab} onPress={() => setTab(t.name)}>
            <Ionicons name={t.icon} size={22} color={tab === t.name ? C.blue : C.muted} />
            <Text style={{ color: tab === t.name ? C.blue : C.muted, fontSize: 11 }}>{t.name}</Text>
          </TouchableOpacity>
        ))}
      </View>
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  app: { flex: 1, backgroundColor: C.bg, paddingTop: Platform.OS === "android" ? StatusBar.currentHeight : 0 },
  center: { flex: 1, alignItems: "center", justifyContent: "center" },
  tabBar: { flexDirection: "row", borderTopWidth: 1, borderTopColor: C.border, paddingVertical: 10 },
  tab: { flex: 1, alignItems: "center", gap: 3 },
});

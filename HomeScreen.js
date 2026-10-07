import { View, Text, TouchableOpacity, StyleSheet } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { COLORS as C } from "../config";

export default function HomeScreen({ sensor, goTo }) {
  const { doorOpen, connected, log, testAlert } = sensor;
  const color = doorOpen ? C.red : C.green;
  const last = log[0];

  return (
    <View style={s.page}>
      <View style={s.header}>
        <Text style={s.title}>OpenAlert</Text>
        <Text style={[s.badge, { color, borderColor: color }]}>{doorOpen ? "TRIGGERED" : "ACTIVE"}</Text>
      </View>

      <View style={[s.card, { borderColor: doorOpen ? C.red : C.border }]}>
        <Text style={s.label}>Front door</Text>
        <View style={[s.ring, { borderColor: color }]} />
        <Text style={s.status}>{doorOpen ? "OPEN" : "CLOSED"}</Text>
        <Text style={s.muted}>{doorOpen ? "Your door was just opened." : "Your door is currently secure."}</Text>
      </View>

      <View style={s.row}>
        <Text style={s.chip}>{connected ? "● ESP32 connected" : "○ ESP32 offline"}</Text>
        <Text style={s.chip}>{connected ? "● Sensor online" : "○ Sensor offline"}</Text>
      </View>

      <View style={[s.row, { justifyContent: "space-between", marginVertical: 14 }]}>
        <Text style={s.muted}>Last activity</Text>
        <Text style={s.value}>{last.text} — {last.time}</Text>
      </View>

      <Text style={s.label}>Quick actions</Text>
      <View style={s.row}>
        <Action icon="pulse" text="Activity" onPress={() => goTo("Activity")} active />
        <Action icon="notifications-outline" text="Test alert" onPress={testAlert} />
        <Action icon="options-outline" text="Settings" onPress={() => goTo("Settings")} />
      </View>
    </View>
  );
}

const Action = ({ icon, text, onPress, active }) => (
  <TouchableOpacity onPress={onPress} style={[s.action, active && { borderColor: C.blue }]}>
    <Ionicons name={icon} size={20} color={active ? C.blue : C.muted} />
    <Text style={[s.actionText, active && { color: C.blue }]}>{text}</Text>
  </TouchableOpacity>
);

const s = StyleSheet.create({
  page: { flex: 1, padding: 20 },
  header: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 20 },
  title: { color: C.text, fontSize: 20, fontWeight: "700" },
  badge: { fontSize: 11, fontWeight: "700", borderWidth: 1, borderRadius: 20, paddingHorizontal: 10, paddingVertical: 4 },
  card: { backgroundColor: C.card, borderWidth: 1, borderRadius: 20, alignItems: "center", padding: 24 },
  label: { color: C.muted, fontSize: 12, marginBottom: 10 },
  ring: { width: 110, height: 110, borderRadius: 55, borderWidth: 5, marginVertical: 16 },
  status: { color: C.text, fontSize: 26, fontWeight: "800" },
  muted: { color: C.muted, fontSize: 13, marginTop: 6 },
  row: { flexDirection: "row", gap: 10, marginTop: 14 },
  chip: { flex: 1, backgroundColor: C.card, color: C.text, fontSize: 12, padding: 12, borderRadius: 12, overflow: "hidden" },
  value: { color: C.text, fontWeight: "600", fontSize: 13 },
  action: { flex: 1, backgroundColor: C.card, borderWidth: 1, borderColor: C.border, borderRadius: 12, alignItems: "center", padding: 14, gap: 6 },
  actionText: { color: C.muted, fontSize: 12 },
});

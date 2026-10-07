// Mao ni ang "utok" sa app: mo-check sa ESP32, mo-save sa log, mo-send og notification.
import { useEffect, useRef, useState } from "react";
import * as Notifications from "expo-notifications";
import { ESP32_IP, DEMO_MODE, POLL_MS } from "../config";

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true, shouldShowBanner: true, shouldShowList: true,
    shouldPlaySound: true, shouldSetBadge: false,
  }),
});

const now = () => new Date().toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });

export default function useDoorSensor() {
  const [doorOpen, setDoorOpen] = useState(false);   // true = open
  const [connected, setConnected] = useState(false); // ESP32 online?
  const [triggered, setTriggered] = useState(false); // naay active alert?
  const [log, setLog] = useState([{ id: 0, text: "System armed", time: now(), type: "info" }]);
  const lastState = useRef(false);

  useEffect(() => { Notifications.requestPermissionsAsync(); }, []);

  const addLog = (text, type) =>
    setLog((old) => [{ id: Date.now(), text, time: now(), type }, ...old]);

  // Tawagon kada naay bag-ong state gikan sa sensor
  function handleNewState(isOpen) {
    if (isOpen === lastState.current) return; // walay nausab
    lastState.current = isOpen;
    setDoorOpen(isOpen);
    if (isOpen) {
      addLog("Door opened — alert sent", "alert");
      setTriggered(true);
      Notifications.scheduleNotificationAsync({
        content: { title: "Door opened", body: `Your front door was opened at ${now()}` },
        trigger: null, // ipakita dayon
      });
    } else {
      addLog("Door closed", "ok");
    }
  }

  // Mo-ask sa ESP32 matag 2 seconds: GET http://<ip>/status -> {"door":"open"} or {"door":"closed"}
  useEffect(() => {
    const timer = setInterval(async () => {
      if (DEMO_MODE) { setConnected(true); return; }
      try {
        const res = await fetch(`http://${ESP32_IP}/status`);
        const data = await res.json();
        setConnected(true);
        handleNewState(data.door === "open");
      } catch (e) {
        setConnected(false);
      }
    }, POLL_MS);
    return () => clearInterval(timer);
  }, []);

  // Test Alert button: i-simulate nga naabri/nagsira ang pultahan
  const testAlert = () => handleNewState(!lastState.current);

  const acknowledge = () => {
    setTriggered(false);
    addLog("Alert acknowledged", "info");
  };

  // Mo-tawag sa ESP32 aron patyon ang buzzer: GET http://<ip>/silence
  const silenceBuzzer = async () => {
    if (!DEMO_MODE) { try { await fetch(`http://${ESP32_IP}/silence`); } catch (e) {} }
    addLog("Buzzer silenced", "info");
  };

  return { doorOpen, connected, triggered, log, testAlert, acknowledge, silenceBuzzer };
}

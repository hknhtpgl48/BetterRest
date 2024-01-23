//
//  ContentView.swift
//  BetterRest
//
//  Created by Hakan Hatipoğlu on 23.01.2024.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeAmount = 1
//    @State private var alertTitle = ""
//    @State private var alertMessage = ""
//    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }

    var sleepTime: Date {
        calculateBedTime()
    }
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                Section("Desired amount of sleep") {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                Section("Daily coffee intake") {
                    Text("Daily coffee intake")
                        .font(.headline)
//                    Stepper("^[\(coffeAmount) cup](inflect: true)", value: $coffeAmount, in: 1...20)
                    Picker("^[\(coffeAmount) cup](inflect: true)", selection: $coffeAmount) {
                        ForEach(1..<21) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }.pickerStyle(.navigationLink)
                }
                Section {
                    Text("Your ideal bedtime is:")
                    Text(sleepTime.formatted(date: .omitted, time: .shortened))
                }
            }
            .navigationTitle("BetterRest")
//            .toolbar {
//                Button("Calculate", action: calculateBedTime)
//            }
//            .alert(alertTitle, isPresented: $showingAlert) {
//                Button("OK") {  }
//            } message: {
//                Text(alertMessage)
//            }
        }
    }
     func calculateBedTime() -> Date {
         var idealBedTime = Date.now
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(hour+minute), estimatedSleep: sleepAmount, coffee: Int64(coffeAmount))
            
            idealBedTime = wakeUp - prediction.actualSleep
        } catch {

        }
         return idealBedTime
    }
}

#Preview {
    ContentView()
}

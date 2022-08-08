//
//  LimitSetterView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 8/3/22.
//

import Foundation
import SwiftUI

/// A view which surfaces controls for editing one of the user's Daily Goals.
struct LimitSetterView: View {
    
    // MARK: - View Variables
    /// Whether or not this view is being presented.
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    /// The name of the limit this view should edit.
    var limitName: String
    /// The goal this limit should edit.
    @Binding var limit: Int
    /// The description text for the limit this view displays.
    var description: String {
        switch limitName {
        case "Song":
            return "Song"
        case "Time":
            return "Second"
        default:
            return ""
        }
    }
    
    // MARK: - View Body
    var body: some View {
        let isLeftButtonDisabled = limit <= 0
        
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    if limitName == "Song" {
                        VStack {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    limit -= 1
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(!isLeftButtonDisabled ? .accentColor : .gray)
                                }
                                .disabled(isLeftButtonDisabled)
                                
                                Spacer()
                                
                                Text("\(limit)")
                                    .font(.system(size: 50))
                                    .fontWeight(.heavy)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                    .frame(width: geometry.size.width / 2.5, height: 75)
                                
                                Spacer()
                                
                                Button(action: {
                                    limit += 1
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.accentColor)
                                }
                                
                                Spacer()
                            }
                            
                            Text("\(description)\(limit != 1 ? "s" : "")")
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                            
                            Spacer()
                        }
                    } else if limitName == "Time" {
                        let timeLimit = secondsToHoursMinutesSeconds(limit)
                        
                        VStack {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    if limit - 60 * 60 >= 0 {
                                        limit -= 60 * 60
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(!isLeftButtonDisabled ? .accentColor : .gray)
                                }
                                .disabled(isLeftButtonDisabled)
                                
                                Spacer()
                                
                                Text("\(timeLimit.0)")
                                    .font(.system(size: 50))
                                    .fontWeight(.heavy)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                    .frame(width: geometry.size.width / 2.5, height: 75)
                                
                                Spacer()
                                
                                Button(action: {
                                    limit += 60 * 60
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.accentColor)
                                }
                                
                                Spacer()
                            }
                            
                            Text("Hour\(timeLimit.0 != 1 ? "s" : "")")
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                            
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    if limit - 60 >= 0 {
                                        limit -= 60
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(!isLeftButtonDisabled ? .accentColor : .gray)
                                }
                                .disabled(isLeftButtonDisabled)
                                
                                Spacer()
                                
                                Text("\(timeLimit.1)")
                                    .font(.system(size: 50))
                                    .fontWeight(.heavy)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                    .frame(width: geometry.size.width / 2.5, height: 75)
                                
                                Spacer()
                                
                                Button(action: {
                                    limit += 60
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.accentColor)
                                }
                                
                                Spacer()
                            }
                            
                            Text("Minute\(timeLimit.1 != 1 ? "s" : "")")
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                        }
                        
                        VStack {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    if limit - 1 >= 0 {
                                        limit -= 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(!isLeftButtonDisabled ? .accentColor : .gray)
                                }
                                .disabled(isLeftButtonDisabled)
                                
                                Spacer()
                                
                                Text("\(timeLimit.2)")
                                    .font(.system(size: 50))
                                    .fontWeight(.heavy)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                    .frame(width: geometry.size.width / 2.5, height: 75)
                                
                                Spacer()
                                
                                Button(action: {
                                    limit += 1
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.accentColor)
                                }
                                
                                Spacer()
                            }
                            
                            Text("Second\(timeLimit.2 != 1 ? "s" : "")")
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            
            // MARK: - Navigation View Settings
            .navigationTitle(Text("\(limitName) Limit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                    }
                }
            })
        }
    }
}

struct LimitSetterView_Previews: PreviewProvider {
    static var previews: some View {
        LimitSetterView(limitName: "Time", limit: .constant(5))
    }
}

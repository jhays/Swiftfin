import CoreData
import SwiftUI
import Defaults

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var viewModel: SettingsViewModel

    @Binding var close: Bool
    @Default(.inNetworkBandwidth) var inNetworkStreamBitrate
    @Default(.outOfNetworkBandwidth) var outOfNetworkStreamBitrate
    @Default(.isAutoSelectSubtitles) var isAutoSelectSubtitles
    @Default(.autoSelectSubtitlesLangCode) var autoSelectSubtitlesLangcode
    @Default(.autoSelectAudioLangCode) var autoSelectAudioLangcode
    @State private var username: String = ""

    func onAppear() {
        username = SessionManager.current.user.username ?? ""
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Playback settings")) {
                    Picker("Default local quality", selection: $inNetworkStreamBitrate) {
                        ForEach(self.viewModel.bitrates, id: \.self) { bitrate in
                            Text(bitrate.name).tag(bitrate.value)
                        }
                    }

                    Picker("Default remote quality", selection: $outOfNetworkStreamBitrate) {
                        ForEach(self.viewModel.bitrates, id: \.self) { bitrate in
                            Text(bitrate.name).tag(bitrate.value)
                        }
                    }
                }

                Section(header: Text("Accessibility")) {
                    Toggle("Automatically show subtitles", isOn: $isAutoSelectSubtitles)
                    SearchablePicker(label: "Preferred subtitle language",
                                     options: viewModel.langs,
                                     optionToString: { $0.name },
                                     selected: Binding<TrackLanguage>(
                                        get: { viewModel.langs.first(where: { $0.isoCode == autoSelectSubtitlesLangcode }) ?? .auto },
                                        set: {autoSelectSubtitlesLangcode = $0.isoCode}
                                     )
                    )
                    SearchablePicker(label: "Preferred audio language",
                                     options: viewModel.langs,
                                     optionToString: { $0.name },
                                     selected: Binding<TrackLanguage>(
                                        get: { viewModel.langs.first(where: { $0.isoCode == autoSelectAudioLangcode }) ?? .auto },
                                        set: { autoSelectAudioLangcode = $0.isoCode}
                                     )
                    )
                }

                Section {
                    HStack {
                        Text("Signed in as \(username)").foregroundColor(.primary)
                        Spacer()
                        Button {
                            let nc = NotificationCenter.default
                            nc.post(name: Notification.Name("didSignOut"), object: nil)

                            SessionManager.current.logout()
                        } label: {
                            Text("Log out").font(.callout)
                        }
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        close = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }.onAppear(perform: onAppear)
    }
}

import Foundation
import SwiftUI

class VideoPlayerCastDeviceSelectorView: UIViewController {
    private var contentView: UIHostingController<VideoPlayerCastDeviceSelector>!
    weak var delegate: PlayerViewController?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            .landscape
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView = UIHostingController(rootView: VideoPlayerCastDeviceSelector(delegate: self.delegate ?? PlayerViewController()))
        self.view.addSubview(contentView.view)
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentView.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.castPopoverDismissed()
    }
}

struct VideoPlayerCastDeviceSelector: View {
    weak var delegate: PlayerViewController!

    init(delegate: PlayerViewController) {
        self.delegate = delegate
    }

    var body: some View {
        NavigationView {
            Group {
                if !delegate.discoveredCastDevices.isEmpty {
                    List(delegate.discoveredCastDevices, id: \.deviceID) { device in
                        HStack {
                            Text(device.friendlyName!)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Button {
                                delegate.selectedCastDevice = device
                                delegate?.castDeviceChanged()
                                delegate?.castPopoverDismissed()
                            } label: {
                                HStack {
                                    Text("Connect")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Image(systemName: "bonjour")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                } else {
                    Text("No Cast devices found..")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Select Cast Destination")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        Button {
                            delegate?.castPopoverDismissed()
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back").font(.callout)
                            }
                        }
                    }
                }
            }
        }.offset(y: UIDevice.current.userInterfaceIdiom == .pad ? 14 : 0)
    }
}

//
//  UIViewController+Ext.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/09/30.
//

import UIKit
import SnapKit

extension UIViewController {
    func setDismissButton(inset: CGFloat) {
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .white
        dismissButton.addTarget(self, action: #selector(didDismissTapped), for: .touchUpInside)
        
        self.view.addSubview(dismissButton)
        dismissButton.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.trailing.equalToSuperview().inset(inset)
            $0.width.height.equalTo(40)
        }
    }
    
    @objc private func didDismissTapped() {
        self.dismiss(animated: false)
    }
}

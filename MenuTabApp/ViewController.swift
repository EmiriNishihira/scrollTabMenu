//
//  ViewController.swift
//  MenuTabApp
//
//  Created by nakamori.emiri on 2024/07/06.
//

import UIKit

class ViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pageViewController: UIPageViewController!
    var segmentedControl: UISegmentedControl!
    var underlineView: UIView!
    var underlineXConstraint: NSLayoutConstraint! // アンダーラインのLeading制約
    var underlineWidthConstraint: NSLayoutConstraint! // アンダーラインのWidth制約
    
    let tabs = ["履歴", "様子", "記録", "お世話"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    func setUpUI() {
        // セグメントコントロールを設定
        segmentedControl = UISegmentedControl(items: tabs)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)

        // UIPageViewControllerを設定
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self

        if let startingViewController = viewControllerAtIndex(0) {
            pageViewController.setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        // 下線ビューを追加
        underlineView = UIView()
        underlineView.backgroundColor = .green
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(underlineView)
        
        // アンダーラインの制約を設定
        underlineXConstraint = underlineView.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor)
        underlineWidthConstraint = underlineView.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 1.0 / CGFloat(tabs.count), constant: 0)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 50),
            
            pageViewController.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            underlineView.heightAnchor.constraint(equalToConstant: 2),
            underlineXConstraint,
            underlineWidthConstraint,
            underlineView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor)
        ])
        
        moveUnderline(to: segmentedControl.selectedSegmentIndex)
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        if let viewController = viewControllerAtIndex(index) {
            let direction: UIPageViewController.NavigationDirection = index > (pageViewController.viewControllers?.first as! ContentViewController).pageIndex ? .forward : .reverse
            pageViewController.setViewControllers([viewController], direction: direction, animated: true, completion: nil)
            
            moveUnderline(to: index)
        }
    }
    
    func moveUnderline(to index: Int) {
        let selectedSegmentWidth = segmentedControl.widthForSegment(at: index)
        let segmentWidth = segmentedControl.frame.width / CGFloat(tabs.count)
        let underlineX = CGFloat(index) * segmentWidth
        
        // アンダーラインの位置と幅を更新
        underlineXConstraint.constant = underlineX
        underlineWidthConstraint.constant = selectedSegmentWidth
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    func viewControllerAtIndex(_ index: Int) -> ContentViewController? {
        if index >= tabs.count {
            return nil
        }

        let contentViewController = ContentViewController()
        contentViewController.pageIndex = index
        contentViewController.titleText = tabs[index]
        return contentViewController
    }

    // UIPageViewControllerDataSource Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! ContentViewController).pageIndex

        if index == 0 {
            return nil
        }

        return viewControllerAtIndex(index - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! ContentViewController).pageIndex

        if index == tabs.count - 1 {
            return nil
        }

        return viewControllerAtIndex(index + 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let viewController = pageViewController.viewControllers?.first as? ContentViewController {
            segmentedControl.selectedSegmentIndex = viewController.pageIndex
            moveUnderline(to: viewController.pageIndex)
        }
    }
}

class ContentViewController: UIViewController {
    
    var pageIndex: Int = 0
    var titleText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        // コンテンツのラベルを作成
        let contentLabel = UILabel()
        contentLabel.text = titleText
        contentLabel.textAlignment = .center
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentLabel)
        
        // Auto Layoutの設定
        NSLayoutConstraint.activate([
            contentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}


import SwiftUI

struct ViewControllerPreview: PreviewProvider {
    static var previews: some View {
        ViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
}

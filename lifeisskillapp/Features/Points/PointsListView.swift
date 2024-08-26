//
//  PointsListView.swift
//  lifeisskillapp
//
//  Created by Karolína Droscová on 05.08.2024.
//

import SwiftUI

struct PointsListView: View {
    let points: [Point]
    let mapButtonAction: (Point) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack() {
                ForEach(points) { point in
                    PointListItem(point: point, mapButtonAction: {
                        mapButtonAction(point)
                    })
                }
            }
        }
    }
}

struct PointListItem: View {
    let point: Point
    let mapButtonAction: () -> Void
    var pointValue: String {
        "\(point.value)"
    }
    
    var body: some View {
        PointListCard {
            contentView
                .background(point.type.color)
        }
    }
    
    private var contentView: some View {
        VStack {
            pointInfoView
            ExDivider(
                color: CustomColors.ListPointCard.foreground.color,
                height: PointListItemConstants.dividerHeight
            )
            mapIconView
        }
    }
    
    private var pointInfoView: some View {
        HStack {
            dateView
            Spacer()
            pointNameView
            Spacer()
            pointsView
        }
        .padding(PointListItemConstants.topBarHorizontalPadding)
    }
    
    private var dateView: some View {
        VStack(alignment: .leading) {
            Text(point.time.getTimeString())
            Text(point.time.getDayString())
            Text(point.time.getYearString())
        }
        .frame(width: PointListItemConstants.dateWidth, alignment: .leading)
        .foregroundStyle(CustomColors.ListPointCard.foreground.color)
        .body2Regular
    }
    
    private var pointNameView: some View {
        Text(point.name)
            .foregroundStyle(CustomColors.ListPointCard.foreground.color)
            .headline3
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var pointsView: some View {
        Text(pointValue)
            .headline2
            .foregroundColor(point.doesPointCount ? CustomColors.ListPointCard.foreground.color : CustomColors.ListPointCard.invalidPoint.color)
            .frame(width: PointListItemConstants.pointsWidth, alignment: .trailing)
    }
    
    private var mapIconView: some View {
        HStack {
            Spacer()
            Button(action: mapButtonAction) {
                SFSSymbols.map.Image
                    .resizable()
                    .squareFrame(size: PointListItemConstants.mapIconSize)
                    .foregroundStyle(CustomColors.ListPointCard.foreground.color)
                    .padding(.horizontal, PointListItemConstants.bottomBarHorizontalPadding)
                    .padding(.top, PointListItemConstants.bottomBarTopPadding)
                    .padding(.bottom, PointListItemConstants.bottomBarBottomPadding)
            }
        }
    }
    
    private enum PointListItemConstants {
        static let dateWidth: CGFloat = 40
        static let pointsWidth: CGFloat = 40
        static let mapIconSize: CGFloat = 20
        static let dividerHeight: CGFloat = 2.5
        static let topBarHorizontalPadding: CGFloat = 12
        static let bottomBarBottomPadding: CGFloat = 12
        static let bottomBarTopPadding: CGFloat = 4
        static let bottomBarHorizontalPadding: CGFloat = 12
    }
}

struct PointsListView_Previews: PreviewProvider {
    static var previews: some View {
        PointsListView(
            points: [Point.MockPoint1, Point.MockPoint2],
            mapButtonAction: { point in
                print("Map button pressed for point: \(point.name)")
            }
        )
    }
}

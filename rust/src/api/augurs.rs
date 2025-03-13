use augurs::{
    ets::{trend::AutoETSTrendModel, AutoETS, AutoSpec},
    forecaster::{
        transforms::{LinearInterpolator, Logit, MinMaxScaler},
        Forecaster, Transformer,
    },
    mstl::MSTLModel,
};
use flutter_rust_bridge::frb;
use serde_json::json;

use super::utils::*;

#[frb]
pub fn augurs_forecaster(csv_data: Vec<u8>, frequency: String) -> std::string::String {
    let sales = read_sales_data(csv_data);
    let n_frequency = get_frequency(frequency);

    let data = sales.as_slice();

    let ets = AutoETS::new(12, "ZZN").unwrap();
    let ets_trend = ets.into_trend_model();
    let mstl = MSTLModel::new(vec![n_frequency],ets_trend);

    // Set up the transformers.
    let transformers = vec![
        LinearInterpolator::new().boxed(),
        MinMaxScaler::new().boxed(),
        // Logit::new().boxed(),
    ];

    // Create a forecaster using the transforms.
    let mut forecaster = Forecaster::new(mstl).with_transformers(transformers);

    // Fit the data into the forecaster through the MSTL model
    forecaster.fit(&data).expect("model should fit");

    // Generate a limited number of predictions (X amount) to focus on short-term accuracy.
    // Short-term predictions are preferred to prevent large deviations
    let in_sample = forecaster
        .predict(4, 0.99)
        .expect("in-sample predictions should work");

    let predictions: Vec<_> = in_sample.point.iter().cloned().collect();
    let intervals: Vec<augurs::ForecastIntervals> =
        in_sample.intervals.iter().cloned().collect();

    let mut intervals_properties = intervals.iter().map(|forecast| {
        (
            format!("{:?}", forecast.level),
            format!("{:?}", forecast.upper),
            format!("{:?}", forecast.lower),
        )
    });

    let (confidence, upper, lower) = intervals_properties.next().unwrap_or((
        "None".to_string(),
        "None".to_string(),
        "None".to_string(),
    ));

    json!({
        "predictions": predictions,
        "confidence": confidence,
        "upper": upper,
        "lower": lower,
    })
    .to_string()
}

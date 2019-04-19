using System;
using Android.App;
using Android.OS;
using Android.Support.Design.Widget;
using Android.Support.V7.App;
using Android.Views;
using Android.Widget;
using Java.Interop;

namespace PeopleerClient
{
    [Activity(Label = "@string/app_name", Theme = "@style/AppTheme.NoActionBar", MainLauncher = true)]
    public class MainActivity : AppCompatActivity
    {

        protected override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            SetContentView(Resource.Layout.activity_main);
        }

        int count = 0;
        [Java.Interop.Export("CreateEventBtn_OnClick")]
        public void CreateEventBtn_OnClick(View view)
        {
            Button btn = FindViewById<Button>(Resource.Id.CreateEventBtn);
            count++;
            btn.Text = "Clicked " + count + " Times";
        }

        int count2 = 0;
        [Java.Interop.Export("JoinEventBtn_OnClick")]
        public void JoinEventBtn_OnClick(View view)
        {
            Button btn = FindViewById<Button>(Resource.Id.JoinEventBtn);
            count2++;
            btn.Text = "Clicked " + count2 + " Times V2.0";
        }
    }
}


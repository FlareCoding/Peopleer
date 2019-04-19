package md5974f83a73766e76866b0cd6171592e3e;


public class MainActivity
	extends android.support.v7.app.AppCompatActivity
	implements
		mono.android.IGCUserPeer
{
/** @hide */
	public static final String __md_methods;
	static {
		__md_methods = 
			"n_onCreate:(Landroid/os/Bundle;)V:GetOnCreate_Landroid_os_Bundle_Handler\n" +
			"n_CreateEventBtn_OnClick:(Landroid/view/View;)V:__export__\n" +
			"n_JoinEventBtn_OnClick:(Landroid/view/View;)V:__export__\n" +
			"";
		mono.android.Runtime.register ("PeopleerClient.MainActivity, PeopleerClient", MainActivity.class, __md_methods);
	}


	public MainActivity ()
	{
		super ();
		if (getClass () == MainActivity.class)
			mono.android.TypeManager.Activate ("PeopleerClient.MainActivity, PeopleerClient", "", this, new java.lang.Object[] {  });
	}


	public void onCreate (android.os.Bundle p0)
	{
		n_onCreate (p0);
	}

	private native void n_onCreate (android.os.Bundle p0);


	public void CreateEventBtn_OnClick (android.view.View p0)
	{
		n_CreateEventBtn_OnClick (p0);
	}

	private native void n_CreateEventBtn_OnClick (android.view.View p0);


	public void JoinEventBtn_OnClick (android.view.View p0)
	{
		n_JoinEventBtn_OnClick (p0);
	}

	private native void n_JoinEventBtn_OnClick (android.view.View p0);

	private java.util.ArrayList refList;
	public void monodroidAddReference (java.lang.Object obj)
	{
		if (refList == null)
			refList = new java.util.ArrayList ();
		refList.add (obj);
	}

	public void monodroidClearReferences ()
	{
		if (refList != null)
			refList.clear ();
	}
}

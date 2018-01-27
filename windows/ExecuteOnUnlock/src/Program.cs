using Microsoft.Win32;
using System;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace ExecuteOnUnlock
{
    class Program
    {
        WindowsSession session = new WindowsSession();
        NotifyIcon icn = new NotifyIcon();

        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            Program p = new Program();
            p.NonStaticMethod();

            MemoryManagement.FlushMemory();

            Application.Run();
        }


        internal void NonStaticMethod()
        {
            session.StateChanged += new EventHandler<SessionSwitchEventArgs>(session_StateChanged);

            //create conextmenustrip
            ContextMenuStrip contextMenuStrip = new ContextMenuStrip();
            contextMenuStrip.Items.Add("run");
            contextMenuStrip.Items.Add("exit");
            contextMenuStrip.ItemClicked += contextMenuStrip_ItemClicked;

            //set the properties to notifyicon
            // icn.Click += new EventHandler(icn_Click);
            icn.Visible = true;
            icn.Icon = System.Drawing.Icon.ExtractAssociatedIcon(Application.ExecutablePath); //ExecuteOnUnlock.Properties.Resources.main;
            icn.ContextMenuStrip = contextMenuStrip;
        }


        internal void contextMenuStrip_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {

            switch (e.ClickedItem.Text)
            {
                case "run" :
                    ExecuteCommand();
                    break;
                case "exit":
                    icn.Dispose();
                    Application.Exit();
                    break;

            }
        }

        internal void write_log(string txt)
        {
            try
            {
                using (StreamWriter outfile = new StreamWriter(Application.StartupPath + "\\log.txt", true))
                {
                    outfile.WriteLine(txt);
                }
            }
            catch(Exception x){}
        }

        internal void session_StateChanged(object sender, SessionSwitchEventArgs e)
        {
            write_log(string.Format("State: {0}\t\tTime: {1} ", e.Reason, DateTime.Now));

            switch (e.Reason)
            {
                case SessionSwitchReason.SessionUnlock:
                    System.Threading.Thread.Sleep(5000);
                    ExecuteCommand();
                    break;
                default:
                    break;
            }

            MemoryManagement.FlushMemory();
        }

        internal void ExecuteCommand()
        {
            if (!File.Exists(Application.StartupPath + "\\start.bat"))
            {
                write_log(string.Format("State: {0}\t\tTime: {1} ", "'start.bat' not found, operation aborted!", DateTime.Now));
                return;
            }

            // https://stackoverflow.com/a/5519517/1320686
            ProcessStartInfo processInfo;
            Process process;

            processInfo = new ProcessStartInfo(Application.StartupPath + "\\start.bat");
            processInfo.CreateNoWindow = true;
            processInfo.UseShellExecute = false;
            processInfo.WorkingDirectory = Application.StartupPath;
            process = Process.Start(processInfo);
           
        }

        public static class MemoryManagement
        {
            [DllImport("kernel32.dll")]
            public static extern bool SetProcessWorkingSetSize(IntPtr proc, int min, int max);

            public static void FlushMemory()
            {
                GC.Collect();
                GC.WaitForPendingFinalizers();
                if (Environment.OSVersion.Platform == PlatformID.Win32NT)
                {
                    SetProcessWorkingSetSize(System.Diagnostics.Process.GetCurrentProcess().Handle, -1, -1);
                }
            }
        }

    }
}
